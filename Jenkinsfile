pipeline {
  agent any
  stages {
	 stage('Verify Branch') {
	   steps {
		 echo "$GIT_BRANCH"
	   }
	 }
	 stage('Run Unit Tests') {
       steps {
         powershell(script: """ 
           cd TaskTronicApp
           dotnet test
           cd ..
         """)
       }
     }
	 stage('Docker Build') {
	   steps {
        powershell(script: 'docker-compose build')     
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
            def image = docker.image("stefantestdocker/carrentalsystem-user-client")
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
  }
}