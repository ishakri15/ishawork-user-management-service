// Define variables used throughout the pipeline
def dockerHubRepo = "ishakri15/ishawork-user-management-service" // e.g., myuser/springboot-app
def imageTag = "${env.BUILD_NUMBER}" // Use Jenkins build number for unique tag

pipeline {
    // Agent 'any' means the pipeline can run on any available Jenkins node
    // For M2, ensure your Jenkins agent is running on the host machine.
    agent any

    // Define environment variables used for Docker Hub login
    environment {
        // You MUST configure a Jenkins Secret Text credential with ID 'dockerhub-credentials'
        // containing your Docker Hub password/token.
        DOCKER_HUB_ID = 'Docker#7989'
    }

    stages {
        stage('Clean Workspace and Checkout') {
            steps {
                echo 'Cleaning up and checking out code...'
                // The SCM checkout is typically done automatically when the job starts
                // If using Git, ensure the Jenkins job is configured with the repo URL.
            }
        }

        stage('Build Spring Boot App') {
            steps {
                echo 'Running Maven build...'
                // IMPORTANT: Use the correct command for your multi-module project
                // If using Gradle: sh './gradlew clean package -x test'
                // If using Maven:
                sh 'mvn clean package -DskipTests'

                // Verify the JAR exists (adjust the path to your final JAR)
                sh "ls -l ishawork-user-management-ms-core/target/*.jar"
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${dockerHubRepo}:${imageTag}"

                // Use the docker build command
                // The -f flag specifies the Dockerfile location (we assume root)
                // The '.' indicates the build context (the root of the project)
                script {
                    def customImage = docker.build("${dockerHubRepo}:${imageTag}", "-f Dockerfile .")

                    // Store the image reference for the next stage
                    // Note: Jenkins automatically uses the Docker daemon on the agent.
                    // Since this is on an M2, it will natively build an ARM64 image.
                    stash name: 'dockerImage', includes: 'target/*'
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo 'Authenticating and pushing image to Docker Hub...'
                // Use the 'withCredentials' block to securely access Docker Hub credentials
                withCredentials([usernamePassword(credentialsId: env.DOCKER_HUB_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        // 1. Authenticate with Docker Hub
                        sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"

                        // 2. Tag the image as 'latest' as well
                        sh "docker tag ${dockerHubRepo}:${imageTag} ${dockerHubRepo}:latest"

                        // 3. Push both tags
                        sh "docker push ${dockerHubRepo}:${imageTag}"
                        sh "docker push ${dockerHubRepo}:latest"

                        // 4. Logout
                        sh "docker logout"
                    }
                }
            }
        }
    }
}