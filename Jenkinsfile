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
        stage('Diagnostics') {
          steps {
              sh '''
                echo "===== Diagnostic Info ====="
                echo "User: $(whoami)"
                echo "Workspace: ${env.WORKSPACE}"
                echo "Node: ${env.NODE_NAME}"
                echo "PATH = ${PATH}"
                echo "MAVEN_HOME = ${MAVEN_HOME}"
                echo "JAVA_HOME = ${JAVA_HOME}"
                echo "Which mvn: $(which mvn || echo "mvn not found")"
                echo "Maven version:"
                mvn -v || /opt/homebrew/bin/mvn -v || echo "mvn version failed"
                echo "Listing mvn path details:"
                ls -l /opt/homebrew/bin/mvn || echo "mvn file not found"
                echo "Environment variables (shell):"
                printenv
                echo "============================"
              '''
            }
        }
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Build & Test') {
            steps {
                    sh '/opt/homebrew/bin/mvn clean compile test package'
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
