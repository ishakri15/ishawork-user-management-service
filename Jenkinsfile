
def dockerHubRepo = "ishakri15/ishawork-user-management-service"

pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'docker-isha-cred'

        // IMAGE_TAG is set from the Jenkins build number at runtime
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Clean Workspace and Checkout') {
            steps {
                echo 'Cleaning workspace and checking out code...'
                // clean workspace if you want (optional)
                deleteDir()
                checkout scm
            }
        }

        stage('Build Spring Boot App') {
            steps {
                echo 'Running Maven build (only core module)...'
                // Build only the core module and its dependencies (faster for multi-module projects)
                sh 'mvn -B -ntp -pl ishawork-user-management-ms-core -am clean package -DskipTests'

                // Debug: show produced files
                sh 'echo "Jar files in target:"; ls -la ishawork-user-management-ms-core/target || true'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image: ${dockerHubRepo}:${env.IMAGE_TAG}"

                    docker.withServer('unix:///var/run/docker.sock') {
                        def image = docker.build("${dockerHubRepo}:${env.IMAGE_TAG}", "-f Dockerfile .")

                        // Optionally tag as latest locally (push stage will push)
                        image.tag('latest')
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Authenticating and pushing image to Docker Hub...'
                // Use withCredentials with the Jenkins credential ID (username/password)
                withCredentials([usernamePassword(credentialsId: env.DOCKER_HUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                        sh "docker push ${dockerHubRepo}:${env.IMAGE_TAG}"
                        sh "docker push ${dockerHubRepo}:latest"
                        sh "docker logout"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finished. Cleanup workspace."
            deleteDir()
        }
    }
}
