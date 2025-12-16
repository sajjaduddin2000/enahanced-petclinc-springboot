pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'enahanced-petclinc-springboot'
        IMAGE_TAG = 'latest'
        TENANT_ID = '299985dd-eac6-4391-84bd-b7cd87f2921e'
        ACR_NAME = 'petclinicacr07'
        ACR_LOGIN_SERVER = 'petclinicacr07.azurecr.io'
        FULL_IMAGE_NAME = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"
        RG = 'bootcamp-rg1'
        AKS_NAME = 'petclinic07-aks'
    }
    
    stages {
        stage('Checkout FROM GIT') {
            steps {
                echo '========== Cloning Repository =========='
                git branch: 'prod', url: 'https://github.com/sajjaduddin2000/enahanced-petclinc-springboot.git'
            }
        }
        
        stage('Compile with Maven') {
            steps {
                echo '========== Compiling Java Code =========='
                sh 'mvn clean compile'
            }
        }
        
        stage('Run Tests') {
            steps {
                echo '========== Running Unit Tests =========='
                sh 'mvn test'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                echo '========== Running Code Quality Analysis =========='
                script {
                    def scannerHome = tool 'SonarQube Scanner'
                    withSonarQubeEnv('SonarQube') {
                        sh 'mvn sonar:sonar -Dsonar.projectKey=petclinic -Dsonar.projectName=PetClinic'
                    }
                }
            }
        }
        
        stage('Maven Package') {
            steps {
                echo '========== Building JAR File =========='
                sh 'mvn clean package -DskipTests'
            }
        }
        
        stage('Docker Build') {
            steps {
                echo '========== Building Docker Image =========='
                script {
                    sh """
                        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}
                    """
                }
            }
        }
        
        stage('Trivy Scan') {
            steps {
                echo '========== Scanning Image for Vulnerabilities =========='
                sh "trivy image --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG} || true"
            }
        }
        
        stage('Azure Login and Push to ACR') {
            steps {
                echo '========== Pushing Image to Azure Container Registry =========='
                withCredentials([usernamePassword(credentialsId: 'azure-acr-spn', usernameVariable: 'AZURE_CLIENT_ID', passwordVariable: 'AZURE_CLIENT_SECRET')]) {
                    sh """
                        az login --service-principal -u \${AZURE_CLIENT_ID} -p \${AZURE_CLIENT_SECRET} --tenant ${TENANT_ID}
                        az acr login --name ${ACR_NAME}
                        docker push ${FULL_IMAGE_NAME}
                    """
                }
            }
        }
        
        stage('Deploy to AKS') {
            steps {
                echo '========== Deploying to Azure Kubernetes Service =========='
                withCredentials([usernamePassword(credentialsId: 'azure-acr-spn', usernameVariable: 'AZURE_CLIENT_ID', passwordVariable: 'AZURE_CLIENT_SECRET')]) {
                    sh """
                        az login --service-principal -u \${AZURE_CLIENT_ID} -p \${AZURE_CLIENT_SECRET} --tenant ${TENANT_ID}
                        az aks get-credentials --resource-group ${RG} --name ${AKS_NAME} --overwrite-existing
                        kubectl apply -f k8s/sprinboot-deployment.yaml
                        kubectl rollout status deployment/petclinic-deployment || true
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo '========== Cleaning Up =========='
            cleanWs()
        }
        success {
            echo '========== Pipeline Succeeded! =========='
        }
        failure {
            echo '========== Pipeline Failed! =========='
        }
    }
}
