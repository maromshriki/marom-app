pipeline {
    agent any

    environment {
        GIT_CREDENTIALS_ID = 'github-creds'
        GIT_REPO_URL = 'https://github.com/maromshriki/marom-app'
        BRANCH = 'main'
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
                    sh 'docker-compose build'  // Build the image using docker-compose
                }
            }
        }

        stage('Run tests') {
            steps {
                sh 'python -m unittest discover -s tests -v'
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
                    withAWS(credentials: 'aws') {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY_NAME}:${IMAGE_TAG}"
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

