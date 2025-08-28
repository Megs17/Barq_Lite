FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app
COPY demo-1-SNAPSHOT.jar /app/app.jar

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
