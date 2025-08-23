package com.example.demo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class LoggerTask {
    private static final Logger log = LoggerFactory.getLogger(LoggerTask.class);

    // Run every 60s
    @Scheduled(fixedRate = 60000)
    public void logMessage() {
        log.info("Hello from BARQ app! Logging every minute.");
    }
}
