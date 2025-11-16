# ------ build stage ------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy entire project (parent + modules)
COPY . .

# Build only the module you need (and its dependencies),
# or drop the -pl if you want to build all modules.
RUN mvn -B -ntp -pl ishawork-user-management-ms-core -am clean package -DskipTests

# ------ runtime stage ------
FROM eclipse-temurin:17-jre
ARG JAR_FILE=/app/ishawork-user-management-ms-core/target/*.jar
ENV APP_HOME=/usr/app

# Create app dir and set ownership
RUN mkdir -p ${APP_HOME} && groupadd -r appuser && useradd -r -g appuser appuser

# Copy built jar as root (before switching user)
COPY --from=build ${JAR_FILE} ${APP_HOME}/app.jar

# Give the non-root user ownership
RUN chown -R appuser:appuser ${APP_HOME}

USER appuser
WORKDIR ${APP_HOME}

EXPOSE 8080

CMD ["java", "-XX:MaxRAMPercentage=80.0", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar"]
