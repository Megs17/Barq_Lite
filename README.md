# BARQ Lite Deployment
BARQ Lite is a small Java web application that prints **"Hello Barq"** on port `8080`. The deployment is divided into **two phases** and can run on multiple VMs. Two Azure VMs were used in this project:

- [https://172.189.56.96:8080](https://172.189.56.96:8080)  
- [https://4.233.136.255:8080](https://4.233.136.255:8080)  

---

## Ansible Roles
```
ansible/
└── roles/
    ├── app/
    │   ├── files/
    │   ├── tasks/
    │   └── vars/
    ├── certificate_check/
    │   ├── files/
    │   ├── tasks/
    │   └── vars/
    ├── date_setup/
    │   ├── files/
    │   ├── tasks/
    │   └── vars/
    ├── files_creation/
    │   ├── files/
    │   ├── tasks/
    │   └── vars/
    └── log_rotation/
        ├── files/
        ├── tasks/
        └── vars/

```

## Deployment Phases

### Phase 1 – JAR Deployment

- **Prerequisites:** OpenJDK 17 installed.  
- **Application:** `demo-0.0.1-SNAPSHOT.jar` deployed under `/opt/barq/releases/<release_id>/`.  
- **Service:** `barq.service` ensures the JAR runs at boot using systemd.  
- **Logs:** Written to `/var/log/barq/`. Rotated daily using `log-lite.sh`.  
- **Certificates:** Stored in `/etc/ssl/patrol/`. Monitored via `cert-lite.sh`.  

**Playbook Roles for Phase 1:**
- `app` – deploys JAR, creates release directories, sets up systemd service.  
- `files_creation` – ensures directories,files and certificates.  
- `log_rotation` – sets up log rotation cron job.  
- `certificate_check` – Monitor Certificates. 
- `date_setup` – sets server timezone to cairo.  


---

### Phase 2 – Docker Deployment

- **No JDK required.**  
- Pulls Docker image `megs17/barq_jar:latest`.  
- Runs container with:
  - `/etc/ssl/patrol` mounted for certificates (read-only).  
  - `/var/log/barq` mounted for logs.  
- Auto-restarts container on crash or VM reboot.  

**Docker Run Example:**
```bash
docker run -d --name barq-lite \
  --restart unless-stopped \
  -p 8080:8080 \
  -v /etc/ssl/patrol:/etc/ssl/patrol:ro \
  -v /var/log/barq:/var/log/barq \
  megs17/barq_jar:latest
```

**Playbook Roles for Phase 2:**
- `app` – installs Docker, pulls and runs container.  
- `files_creation` – ensures certificates and log directories exist.
- `log_rotation` – sets up log rotation and creates cron job.  
- `certificate_check` – Monitor Certificates and creates cron job. 
- `date_setup` – sets server timezone to Cairo.  

---

## Bash Scripts

### 1. `log-lite.sh`
- Rotates and compresses `/var/log/barq/barq.log`.  
- Keeps last 7 days of logs.  
- Scheduled at `01:10` daily via cron.

### 2. `cert-lite.sh`
- Checks `/etc/ssl/patrol/*.crt`.  
- Generates `/var/reports/cert-lite.txt` with expiration info.  
- Scheduled at `7:00` daily via cron.

---

## Azure VMs

- **VM 1:** [https://172.189.56.96:8080](https://172.189.56.96:8080)  
- **VM 2:** [https://4.233.136.255:8080](https://4.233.136.255:8080)  

Both phases can be deployed on the same VMs, depending on your approach.

## Notes

- The application is lightweight and only serves a simple page with "Hello Barq" at port 8080.  
- Phase 1 requires manual management of JAR releases and systemd.  
- Phase 2 uses Docker for easier deployment and portability.

## Hint
- Instead of using Bash scripts for log rotation, you can use the system’s logrotate utility
- Note: These Azure VMs are temporary and will automatically shut down after 3 days (Aug 26 2025).