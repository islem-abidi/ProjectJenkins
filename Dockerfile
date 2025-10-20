FROM openjdk:17-alpine


WORKDIR /app


COPY TP-Projet-0.0.1-SNAPSHOT.jar app.jar


EXPOSE 8083


ENTRYPOINT ["java", "-jar", "app.jar"]
