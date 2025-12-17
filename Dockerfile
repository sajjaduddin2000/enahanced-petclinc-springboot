# Stage 1: Build with Maven
FROM maven:3.8.5-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Runtime with Eclipse Temurin (OpenJDK)
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/target/petclinic.war app.war
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.war"]
