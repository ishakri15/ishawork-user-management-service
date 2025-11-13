pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        MVN_CMD = "mvn"
    }

    tools {
        // Use the name of the Maven installation configured in Jenkins → Global Tool Configuration
        maven 'Maven3'
        // You could also specify a JDK tool if needed:
        // jdk 'JDK17'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Build & Test') {
            steps {
            withMaven(maven: 'Maven3') {
                      sh 'mvn clean compile test package'
            }
        }

        stage('Publish Artifacts') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Example: deploy or copy artifacts only on main branch
                    echo "Publishing artifacts for main branch..."
                    // Add deploy logic here
                }
            }
        }

        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Deploying to DEV environment..."
                    // Add your dev deployment steps here
                }
            }
        }

        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    input message: 'Approve deployment to PRODUCTION?', ok: 'Deploy'
                    echo "Deploying to PRODUCTION environment..."
                    // Add your production deployment steps here
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
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
