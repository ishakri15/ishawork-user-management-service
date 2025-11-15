pipeline {
    agent any

    environment {
        PATH    = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        MVN_CMD = "/opt/homebrew/bin/mvn"
        IMAGE   = "ishawork-user-management-service:${env.BUILD_NUMBER}"
        CONTAINER_NAME = "ishawork-user-management-app-${env.BUILD_NUMBER}"
    }

    tools {
        maven 'Maven3'
        // jdk 'JDK17'   // uncomment if you configured JDK tool in Jenkins
    }

    stages {
        stage('Diagnostics') {
            steps {
                script {
                    echo "===== Diagnostic Info ====="
                    echo "User         : ${sh(script:'whoami', returnStdout:true).trim()}"
                    echo "Workspace    : ${env.WORKSPACE}"
                    echo "Node         : ${env.NODE_NAME}"
                    echo "PATH         : ${env.PATH}"
                    echo "MAVEN_HOME   : ${env.MAVEN_HOME}"
                    echo "JAVA_HOME    : ${env.JAVA_HOME}"
                    echo "MVN_CMD      : ${env.MVN_CMD}"
                    echo "IMAGE        : ${env.IMAGE}"
                    echo "============================"
                }
                sh '''
                    echo "Which mvn: $(which mvn || echo 'mvn not found')"
                    ${MVN_CMD} -v || echo "Maven not found at expected path"
                    ls -l ${MVN_CMD} || echo "Maven binary missing"
                    printenv | sort
                '''
            }
        }

        stage('Checkout') {
            steps {
                script {
                    echo "Checking out code from SCM..."
                    checkout scm
                    echo "Checkout complete."
                }
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    echo "Building the project (multi-module) with Maven..."
                }
                sh '''
                    echo "Running: ${MVN_CMD} clean install -DskipDocker"
                    ${MVN_CMD} clean install -DskipDocker
                '''
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker image ${IMAGE}"
                }
                sh '''
                    docker build -t ${IMAGE} .
                '''
            }
        }

        stage('Docker Run') {
            steps {
                script {
                    echo "Stopping any running container named ${CONTAINER_NAME}"
                }
                sh '''
                    docker rm -f ${CONTAINER_NAME} || true
                    echo "Running container ${CONTAINER_NAME} from image ${IMAGE}"
                    docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${IMAGE}
                '''
            }
        }

        stage('Docker Status') {
            steps {
                script {
                    echo "Listing running containers"
                }
                sh '''
                    docker ps
                    docker logs ${CONTAINER_NAME}
                '''
            }
        }

        stage('Clean up') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "Cleanup or deploy logic for main branch (optional)"
                }
            }
        }
    }

    post {
        always {
            junit '**/target/surefire-reports/*.xml'
            archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
        }
        success {
            echo '✅ Pipeline succeeded!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}