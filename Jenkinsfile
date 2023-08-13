pipeline {
    agent any
    environment {
        registry='huarami/vproappimg'
        registryCredential='dockerhub'
    }

    stages {

        stage ('Build') {
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            } 
        }

        stage ('Unit Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage ('Integration Test') {
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
        }

        stage ('Checkstyle Analysis') {
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
        }

        stage ('Build Image') {
            steps {
                script {
                    dockerImage=docker.build registry + ":$BUILD_NUMBER"
                }
            }
        }

        stage ('Push Image to DockerHub') {
            steps {
                script {
                    docker.withRegistry('',registryCredential) {
                        dockerImage.push("$BUILD_NUMBER")
                    }
                }
            }
        }

        stage ('Remove unused Image') {
            steps {
                sh "docker rmi $registry:$BUILD_NUMBER"
            }
        }

        stage ('SonarQube Analysis') {
            environment {
                scannerHome = tool 'sonar'
            }

            steps {
                withSonarQubeEnv('sonar') {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                   -Dsonar.projectName=vprofile-repo \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }

                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage ('Deploy to Kubernetes') {
            agent { label 'KUBE' }
            steps {
                sh "helm upgrade --install --force vprofile helm/vcharts --set appimg=${registry}:${BUILD_NUMBER} --namespace prod"
            }
        }
    }
}