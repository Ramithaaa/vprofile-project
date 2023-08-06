pipeline {
    agent any
    environment {
        registryCredential="dockerhub"
        registry="huarami/vproappimg"
    }

    stages {
        stage('BUILD') {
            steps {
                sh "mvn clean install -DskipTests"
            }
        }
        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage('build image') {
            steps {
                script {
                    dockerImage=docker.build registry

                }
            }
        }
        stage('push') {
            steps {
                script {
                    docker.withRegistry('',registryCredential) {
                        dockerImage.push('v1')
                    }
                }
            }
        }
    }
}