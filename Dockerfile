# syntax=docker/dockerfile:experimental
ARG  LOGIN_SERVER=test
ARG  REPOSITORY=test
ARG  TAG=latest
from ${LOGIN_SERVER}/${REPOSITORY}:${TAG}
WORKDIR /workspace/app

COPY mvnw .
COPY mvn .mvn
COPY pom.xml .
COPY src src
RUN chmod +x mvnw
RUN --mount=type=cache,target=/root/.m2 ./mvnw install -DskipTests
WORKDIR /workspace/app/target/dependency
RUN jar -xf ../*.jar

FROM openjdk:8-jdk-alpine
RUN addgroup -S demo && adduser -S demo -G demo
VOLUME /tmp
USER demo
ARG DEPENDENCY=/workspace/app/target/dependency
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
ENTRYPOINT ["java","-noverify","-XX:TieredStopAtLevel=1","-cp","app:app/lib/*","-Dspring.main.lazy-initialization=true","com.example.demo.DemoApplication"]
