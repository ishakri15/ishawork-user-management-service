# Use a suitable JDK base with better multi-platform support
FROM **eclipse-temurin:17-jdk-jfr** # Note: The '*-jfr' tag is a good, stable choice for production apps.
# Alternatively, use 'eclipse-temurin:17-jdk' if you prefer.

ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar

ENTRYPOINT ["java","-jar","/app.jar"]