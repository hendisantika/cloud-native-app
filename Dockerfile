FROM eclipse-temurin:23-jdk
LABEL authors="hendisantika"
WORKDIR /app
COPY target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
