pipeline {
  agent any

  stages {
    stage('run the tests') {
      agent {
        docker {
          image 'python:3.7-slim'
          reuseNode true
        }
      }

      steps {
        sh 'npm i'
        sh 'python /app/tests/test_hello.py'
      }
    }

    stage('Build') {
      steps {
          sh 'docker build -t python_app:latest .'
      }
    }
  }
}
