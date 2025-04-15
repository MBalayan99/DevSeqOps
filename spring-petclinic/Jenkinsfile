pipeline {
    agent any

    environment {
        REPO_MAIN = "main"
        REPO_MR = "mr"
        IMAGE_NAME = "spring-petclinic"
    }

    stages {
        stage('Checkout') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                checkout scm
            }
        }

        stage('Checkstyle') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn checkstyle:checkstyle'
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '**/checkstyle-result.xml'
                }
            }
        }

        stage('Test') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage('Build') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    sh 'mvn clean install -DskipTests'
                }
            }
        }

        stage('Docker Image for MR') {
            when {
                expression {
                    return env.BRANCH_NAME?.startsWith('other-')
                }
            }
            steps {
                script {
                    def shortCommit = env.GIT_COMMIT.substring(0, 7)
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-credentials',
                        usernameVariable: 'DOCKER_CREDS_USR',
                        passwordVariable: 'DOCKER_CREDS_PSW'
                    )]) {
                        sh """
                        echo "${DOCKER_CREDS_PSW}" | docker login -u "${DOCKER_CREDS_USR}" --password-stdin
                        docker build -t ${IMAGE_NAME}:${shortCommit} .
                        docker tag ${IMAGE_NAME}:${shortCommit} ${DOCKER_HUB_USR}/${REPO_MR}:${shortCommit}
                        docker push ${DOCKER_HUB_USR}/${REPO_MR}:${shortCommit}
                        """
                    }
                }
            }
        }

        stage('Docker Image for main branch') {
            when {
                expression {
                    return env.BRANCH_NAME == 'main' || env.BRANCH_NAME?.contains('main')
                }
            }
            steps {
                script {
                    def shortCommit = env.GIT_COMMIT.substring(0, 7)
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-credentials',
                        usernameVariable: 'DOCKER_HUB_USR',
                        passwordVariable: 'DOCKER_HUB_TOKEN'
                    )]) {
                        sh """
                        echo "${DOCKER_HUB_TOKEN}" | docker login -u "${DOCKER_HUB_USR}" --password-stdin
                        docker build -t ${IMAGE_NAME}:${shortCommit} .
                        docker tag ${IMAGE_NAME}:${shortCommit} ${DOCKER_HUB_USR}/${REPO_MAIN}:${shortCommit}
                        docker push ${DOCKER_HUB_USR}/${REPO_MAIN}:${shortCommit}
                        """
                    }
                }
            }
        }
    }
}