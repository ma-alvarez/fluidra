stages {
    stage('Clone repository') { 
        steps { 
            script{
                checkout scm
            }
        }
    }
    stage('Build') { 
        steps { 
            script{
                //Build docker image using Dockerfile provided
                app = docker.build()
            }
        }
    }
    stage('Push') {
        steps {
            script{
                //push docker image to registry and tag using build number and latest tags
                docker.withRegistry(<registry_url>) {
                    app.push("${env.BUILD_NUMBER}")
                    app.push("latest")
                }
            }
        }
    }
    stage('Deploy'){
        steps {
            //Deploy the image to kubernetes 
            sh 'kubectl apply -f deployment.yml'
        }
    }

}