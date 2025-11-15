# ----------------------------------------------------------------------
# STAGE 1: BUILD THE APPLICATION (Uses a full JDK + Maven)
#
# We use a multi-arch image (Eclipse Temurin) which automatically detects
# the M2 chip's linux/arm64/v8 architecture and pulls the correct build image.
# ----------------------------------------------------------------------
FROM maven:3.9-eclipse-temurin-17 AS build

# Set the working directory for the build process
WORKDIR /app

# Copy the Maven project files (pom.xml) first to leverage Docker layer caching.
# If only the source code changes, Maven dependencies won't need to be redownloaded.
COPY pom.xml .
COPY settings.xml .
# Download project dependencies
# A dummy execution helps populate the local repository cache.
RUN mvn dependency:go-offline

# Copy the entire source code
COPY src ./src

# Compile the code and package it into an executable JAR.
# Replace 'package' with 'install' if your build produces multiple artifacts.
RUN mvn clean package -DskipTests

# ----------------------------------------------------------------------
# STAGE 2: RUNTIME (Uses a minimal JRE)
#
# Uses the smallest possible JRE image that supports Java 17 on ARM64.
# 'eclipse-temurin:17-jre-alpine' is based on Alpine Linux and is extremely small.
# ----------------------------------------------------------------------
FROM eclipse-temurin:17-jre

# Set the argument for the application JAR file name (change this to match your artifact)
ARG JAR_FILE=target/*.jar
ENV APP_HOME=/usr/app

# Create a non-root user (best practice for security)
RUN addgroup --system appuser && adduser -S -G appuser appuser
# Set the application directory and ensure the appuser owns it
RUN mkdir ${APP_HOME}
USER appuser
WORKDIR ${APP_HOME}

# Copy the built JAR file from the 'build' stage into the final image
# We rely on the naming convention of a typical Spring Boot/Maven JAR.
COPY --from=build /app/${JAR_FILE} app.jar

# Define the port the container should expose (e.g., for a Spring Boot app)
EXPOSE 8080

# The command to run the application (Adjust JVM options as needed)
# Using 'exec' form (JSON array) is recommended by Docker
CMD ["java", "-XX:MaxRAMPercentage=80.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]