pipeline {
    agent any

    environment {
        GIT_CREDENTIALS_ID = 'github-creds'
        GIT_REPO_URL = 'https://github.com/maromshriki/marom-app'
        BRANCH = 'main' 
        IMAGE_NAME= 'marom/jenkins'
    }

    stages {
        stage('Checkout') {
            steps {
                git credentialsId: "${GIT_CREDENTIALS_ID}", url: "${GIT_REPO_URL}", branch: "${BRANCH}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t $IMAGE_NAME .'  // Build the image using docker-compose
                }
            }
        }

        stage('Run tests') {
            steps {
                sh 'docker run  -d $IMAGE_NAME sh -c "python3 -m unittest discover -s tests -v"'
            }
        }

        stage('Push changes (if any)') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh '''
                        git config user.name "maromshriki"
                        git config user.email "marom.shriki@gmail.com"

                        if ! git diff --quiet; then
                            git add .
                            git commit -m "Auto commit by Jenkins after successful tests"
                            git push https://${GIT_USERNAME}:${GIT_PASSWORD}@${GIT_REPO_URL#https://} HEAD:${BRANCH}
                        else
                            echo "No changes to push."
                        fi'''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    
                        sh 'aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com' 
                        sh 'docker tag marom/jenkins:latest 992382545251.dkr.ecr.us-east-1.amazonaws.com/marom/jenkins:latest'
                    }
                }
            }
  
        stage('Push to ECR') {
            steps {
                script {
                    sh '''docker push 992382545251.dkr.ecr.us-east-1.amazonaws.com/marom/jenkins:latest'''
                }
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed – no push or deployment executed.'
        }
    }
}

