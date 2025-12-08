pipeline {
    agent any
    tools {
        maven 'maven'
    }
    environment{
        IMAGE_NAME = 'enahanced-petclinc-springboot'
        IMAGE_TAG = 'latest'
        TENANT_ID ='1d1dbec3-5cd3-4d06-854f-e719dcd693dd'
        ACR_NAME = 'petclinicacr07'
        ACR_LOGIN_SERVER = 'petclinicacr07.azurecr.io'
        FULL_IMAGE_NAME = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
        RG              = "bootcamp-rg"
        NAME            = "petclinic-aks"
    }
    stages {
        stage('Checkout FROM GIT') {
            steps {
                git branch: 'prod' , url: 'https://github.com/sajjaduddin2000/enahanced-petclinc-springboot.git'
        }
      }
        // stage('Validate with Maven ') {
        //     steps {
        //         sh 'mvn validate'
        //     }
        // }
        // stage('Compile with Maven ') {
        //     steps {
        //         sh 'mvn compile'
        //     }
        // }
        // stage('Sonar Analysis ') {
        //     environment {
        //         SCANNER_HOME = tool 'Sonar-scanner'
        //     }   
        //     steps {
        //         withSonarQubeEnv('sonarserver') {
        //             sh '''${SCANNER_HOME}/bin/sonar-scanner \
        //             -Dsonar.organization=bkrrajmali \
        //             -Dsonar.projectName=springbootjavaapp \
        //             -Dsonar.projectKey=springbootjavaapp \
        //             -Dsonar.java.binaries=.
        //           '''
        //         }
        //     }         
        // }
         stage('Maven Package ') {
            steps {
                sh 'mvn package'
            }
        }
        // stage('Sonar Quality Gate') {
        //     steps {
        //         timeout(time: 1, unit: 'MINUTES') {
        //             waitForQualityGate abortPipeline: true, credentialsId: 'sonar'
        //         }
        //     }
        // }
        stage('Docker Build') {
            steps {
                script {
                    echo "Building Docker Image......."
                    docker.build ("${IMAGE_NAME}:${IMAGE_TAG}") 
                }
            }
        }
        stage('Azure Login TO ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-acr-spn', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
                    script {
                        echo "Azure Login Started"
                        sh '''
                        az login --service-principal -u $AZURE_USERNAME -p $AZURE_PASSWORD --tenant $TENANT_ID
                        az acr login --name $ACR_NAME
                        '''
                    }
                }
            }
        }
        stage('Docker Push to ACR') {
            steps {
                script {
                    echo "Docker Image Push to ACR"
                    sh '''
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}
                   
                    docker push ${FULL_IMAGE_NAME}
                    '''
                }
            }
        }
        stage('Azure Login TO AKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-acr-spn', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
                    script {
                        echo "Azure Login to AKS"
                        sh '''
                        az login --service-principal -u $AZURE_USERNAME -p $AZURE_PASSWORD --tenant $TENANT_ID
                        az aks get-credentials --resource-group $RG --name $NAME --overwrite-existing
                        '''
                    }
                }
            }
        }
        stage('Deploy to AKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-acr-spn', usernameVariable: 'AZURE_USERNAME', passwordVariable: 'AZURE_PASSWORD')]) {
                    script {
                        echo "Azure Login to AKS"
                        sh '''
                        az login --service-principal -u $AZURE_USERNAME -p $AZURE_PASSWORD --tenant $TENANT_ID
                        kubectl apply -f k8s/sprinboot-deployment.yaml
                        '''
                    }
                }
            }
        }
    }
}