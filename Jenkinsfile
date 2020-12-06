pipeline {
  agent any
  stages {
	 stage('Verify Branch') {
	   steps {
		    echo "$GIT_BRANCH"
	   }
	 }
   stage('Pull Changes') {
      steps {
        powershell(script: "git pull origin main")
      }
   }
	 stage('Run Unit Tests') {
       steps {
         powershell(script: """ 
           cd Server
           dotnet test
           cd ..
         """)
       }
   }
	 stage('Docker Build Production') {
     when { branch 'main' }
	   steps {
        powershell(script: 'docker-compose build')
        powershell(script: 'docker build -t stefantestdocker/carrentalsystem-user-client-production --build-arg configuration=production ./Client')   
        powershell(script: 'docker images -a')
	   }
	 }
	 stage('Run Test Application') {
      steps {
        powershell(script: 'docker-compose up -d')    
      }
    }
   stage('Run Integration Tests') {
    steps {
      powershell(script: './Tests/ContainerTests.ps1') 
    }
   }
   stage('Stop Test Application') {
    steps {
      powershell(script: 'docker-compose down') 
      // powershell(script: 'docker volumes prune -f')   		
    }
    post {
      success {
        echo "Build successfull! Ready for deploy! :)"
      }
      failure {
        echo "Build failed! You should receive an e-mail! :("
      }
    }
  }
	stage('Push Images') {
      // when { branch 'main' }
      steps {
	  // script runs the whole block like single transaction, DockerHub
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentials') {
            def image = docker.image("stefantestdocker/carrentalsystem-identity-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentials') {
            def image = docker.image("stefantestdocker/carrentalsystem-dealers-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentials') {
            def image = docker.image("stefantestdocker/carrentalsystem-notifications-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentials') {
            def image = docker.image("stefantestdocker/carrentalsystem-statistics-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentials') {
            def image = docker.image("stefantestdocker/carrentalsystem-admin-client")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentials') {
            def image = docker.image("stefantestdocker/carrentalsystem-user-client-production")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
        script {
          docker.withRegistry('https://index.docker.io/v1/', 'DockerHubCredentials') {
            def image = docker.image("stefantestdocker/carrentalsystem-watchdog-service")
            image.push("1.0.${env.BUILD_ID}")
            image.push('latest')
          }
        }
      }
    }
    stage('Deploy Production') {
	    when { branch 'main' }
      steps {
		    echo "1.0.${env.BUILD_ID}"
        withKubeConfig([credentialsId: 'ProductionServer', serverUrl: 'https://34.70.119.152']) {
          powershell(script: 'kubectl apply -f ./.k8s/.environment/production.yml') 
          powershell(script: 'kubectl apply -f ./.k8s/databases') 
          powershell(script: 'kubectl apply -f ./.k8s/event-bus') 
          powershell(script: 'kubectl apply -f ./.k8s/web-services') 
          powershell(script: 'kubectl apply -f ./.k8s/clients') 
          powershell(script: 'kubectl set image deployments/user-client user-client=stefantestdocker/carrentalsystem-user-client-production:${env.prodVersion}')
        }
      }
      post {
	      success {
	        echo "Build Production completed!"
	      failure {
	        echo "Build Production failed!"
      }
    }
  }
}