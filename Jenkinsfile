pipeline {
  agent any

    environment{
        WEBHOOK_URL = credentials('Prod_Discord')
    }

  stages {
        stage('Build') {
      steps {
          sh 'docker build -t python_app:testing .'
      }
      post {
        success {
            echo "======== Building the image Done ========"
        }
        failure {
          echo "======== Building the image failed ========"
          discordSend description: "Jenkins Pipeline Build", thumbnail: "https://jenkins.io/images/logos/ninja/256.png",footer: "Building the image failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
        }
      }
    }


        stage('run the tests') {

      agent {
        docker {
          image 'python_app:testing'
          reuseNode true
        }
      }

      steps {
        sh '''
           ls
           python tests/test_hello.py
           '''
      }
      post {
        success {
          echo "======== testing Done ========"
        }
        failure {
          echo "======== testing failed ========"
          discordSend description: "Jenkins Pipeline Build", thumbnail: "https://jenkins.io/images/logos/ninja/256.png",footer: "testing failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
        }
      }
    }


        stage('Tag Docker image if its successful') {
      steps {
        sh 'docker tag python_app:testing python_app:stable'
        sh 'docker image ls'
      }
    }


        stage('stop the current production') {
      steps {
        sh '''
                cd /Botit/deployment
                docker-compose down
                '''
      }
      post {
        success {
            echo "======== Stoping current Prouduction Done ========"
        }
        failure {
            echo "======== Stoping current Prouduction failed ========"
        discordSend description: "Jenkins Pipeline Build", thumbnail: "https://jenkins.io/images/logos/ninja/256.png",footer: "Stoping current Prouduction failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
      }
    }
    }


    stage('start the new production') {
      steps {
        sh '''
                cd /Botit/deployment
                docker-compose up -d
                '''
      }
      post {
        success {
            echo "======== heeeeey we have new version right now ========"
            discordSend description: "heeeeey we have new version right now", thumbnail: "https://jenkins.io/images/logos/ninja/254.png",footer: "heeeeey we have new version right now", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
        }
        failure {
            echo "======== start the new production failed ========"
            discordSend description: "Jenkins Pipeline Build", thumbnail: "https://jenkins.io/images/logos/ninja/256.png",footer: "start the new production failed", result: currentBuild.currentResult, title: JOB_NAME, webhookURL: WEBHOOK_URL
      }
      }
    }






  }

  	post {

		  always {
            sh 'docker container prune -f'
            sh 'docker system prune -a -f'
      }

      failure{
        sh 'docker image rm python_app:testing'
      }

	}

}
















