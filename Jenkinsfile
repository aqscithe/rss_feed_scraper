pipeline {
  agent none
  options {
    withAWS(region: 'us-west-2', credentials: 'aws')
  }
  environment {
    AWS_ACCESS_KEY_ID = getAccessKey()
    AWS_SECRET_ACCESS_KEY = getSecretKey()
    DOPPLER_SERVICE_TOKEN = getDopplerToken()
    REGION = 'us-west-2'
  }
  stages {
    // Build Rust Cargo Lambda Image
    stage('Build Cargo Lambda') {
      agent { 
        dockerfile {
          filename 'Dockerfile'
          additionalBuildArgs '--build-arg AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}'
          additionalBuildArgs '--build-arg AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}'
          additionalBuildArgs '--build-arg DOPPLER_SERVICE_TOKEN=${DOPPLER_SERVICE_TOKEN}'
          additionalBuildArgs '--build-arg REGION=${REGION}'

        } 
      }
      when {
        expression { BRANCH_NAME ==~ /(aws-lambda\/main)/ }
      }
      steps {
        sh 'echo $USER'
      } 
    }
  }
}

String getAccessKey() {
  withCredentials([usernamePassword(credentialsId: 'aws', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_KEY')]) {
    return "$ACCESS_KEY"
  }
}

String getSecretKey() {
  withCredentials([usernamePassword(credentialsId: 'aws', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_KEY')]) {
    return "${SECRET_KEY}"
  }
}

String getDopplerToken() {
  withCredentials(bindings: [string(credentialsId: 'doppler-rss-feed-scraper-prd-token', variable: 'DOPPLER_SERVICE_TOKEN')]) {
    return "${DOPPLER_SERVICE_TOKEN}"
  }
}
