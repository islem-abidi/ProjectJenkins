pipeline {
    agent any

    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }

    environment {
        SONAR_INSTALL = 'SQ' 
        DOCKERHUB_CREDENTIALS = 'dockerhub-id' // ID des credentials Docker Hub dans Jenkins
        IMAGE_NAME = 'islemab/restaurant-app'
        IMAGE_TAG = 'v1'
    }

    stages {

        // ---------------- CI ----------------
        stage('1 - Checkout (Git)') {
            steps {
                checkout scm
            }
        }

        stage('2 - Maven Clean') {
            steps {
                echo 'Nettoyage du projet...'
                sh 'mvn -B clean'
            }
        }

        stage('3 - Maven Compile') {
            steps {
                echo 'Compilation du projet'
                sh 'mvn -B -DskipTests=true compile'
            }
        }

        stage('4 - SonarQube Analysis') {
            steps {
                echo 'Lancement de l’analyse SonarQube'
                withSonarQubeEnv("${SONAR_INSTALL}") {
                    sh 'mvn -B sonar:sonar'
                }
            }
        }

        stage('5 - Build & Archive JAR') {
            steps {
                echo 'Construction du package final'
                sh 'mvn -B -DskipTests=true package'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Quality Gate') {
            steps {
                echo 'Vérification du Quality Gate SonarQube...'
                timeout(time: 15, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        // ---------------- CD ----------------
        stage('6 - Build Docker Image') {
            steps {
                script {
                    echo "Création de l'image Docker..."
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('7 - Push Docker Image') {
            steps {
                script {
                    echo "Connexion à Docker Hub et push..."
                    withCredentials([usernamePassword(credentialsId: "${DOCKERHUB_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('8 - Deploy to Minikube') {
            steps {
                echo "Déploiement MySQL et backend sur Minikube..."
                sh 'kubectl apply -f mysql-secret.yaml'
                sh 'kubectl apply -f mysql-deployment.yaml'
                sh 'kubectl apply -f restaurant-app-deployment.yaml'
                sh 'kubectl apply -f restaurant-app-service.yaml'
            }
        }
    }

    post {
        success {
            echo 'Pipeline CI/CD terminé avec succès '
        }
        failure {
            echo 'Échec du pipeline '
        }
    }
}
