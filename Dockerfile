FROM openjdk:17-alpine

WORKDIR /app

# Copier le JAR généré depuis le dossier target
COPY target/TP-Projet-0.0.1-SNAPSHOT.jar app.jar

EXPOSE 8083

ENTRYPOINT [\"java\", \"-jar\", \"app.jar\"]
