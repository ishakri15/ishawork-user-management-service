# ----------------------------------------------------------------------
# STAGE 1: BUILD THE APPLICATION
# Base image for building: Maven 3.9 + Temurin JDK 17.
# ----------------------------------------------------------------------
FROM maven:3.9-eclipse-temurin-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the parent pom.xml first to optimize caching (downloads dependencies)
COPY pom.xml .

# Download project dependencies based on the pom.xml structure
# This caches dependencies, so subsequent builds are faster if only code changes.
RUN mvn dependency:go-offline

# Copy the actual source code and module directories
# Ensure these two directories exist in the same folder as the Dockerfile.
COPY ishawork-user-management-service/ishawork-user-management-ms-core ./ishawork-user-management-service/ishawork-user-management-ms-core
#COPY ishawork-user-management-service/ishawork-user-management-rest-api ./ishawork-user-management-service/ishawork-user-management-rest-api

# Compile the entire multi-module project and package the executable JAR
RUN mvn clean package -DskipTests

# ----------------------------------------------------------------------
# STAGE 2: RUNTIME
# Base image for running: Minimal Temurin JRE 17 (non-Alpine for stability).
# ----------------------------------------------------------------------
FROM eclipse-temurin:17-jre

# The REST API module contains the final executable Spring Boot JAR.
ARG JAR_FILE=ishawork-user-management-ms-core/target/*.jar
ENV APP_HOME=/usr/app

# Create a non-root user for security best practices
RUN groupadd -r appuser && useradd -r -g appuser appuser
# Create application directory and set permissions
RUN mkdir ${APP_HOME}
USER appuser
WORKDIR ${APP_HOME}

# Copy the built JAR file from the 'build' stage into the final image
COPY --from=build /app/${JAR_FILE} app.jar

# Expose the standard Spring Boot port
EXPOSE 8080

# Command to run the application
# Standard recommended command for Spring Boot in a container
CMD ["java", "-XX:MaxRAMPercentage=80.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]