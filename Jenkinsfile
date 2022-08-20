pipeline {
  agent { dockerfile true }
  options {
    withAWS(region: 'us-west-2', credentials: 'aws')
  }
  environment {}
  post {}
  stages {
    // Build Rust Cargo Lambda Image
    stage('Build Cargo Lambda') {
      when {
        expression { BRANCH_NAME ==~ /(aws-lambda\/main)/ }
      }
      environment {
        REGION = 'us-west-2'
      }
      options {}
      steps {
        withCredentials(bindings: [string(credentialsId: 'doppler-rss-feed-scraper-prd-token', variable: 'DOPPLER_SERVICE_TOKEN')]) {
          withCredentials([usernamePassword(credentialsId: 'aws', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_KEY')]) {
            sh 'export AWS_ACCESS_KEY_ID=${ACCESS_KEY} && export AWS_SECRET_ACCESS_KEY=${SECRET_KEY}'
            sh 'export HISTIGNORE="doppler*"'
            sh 'echo "${DOPPLER_SERVICE_TOKEN}" | doppler configure set token --scope /'
            sh '''
              doppler run --command="cargo lambda deploy --region ${REGION} --iam-role \
                $LAMBDA_IAM_ROLE rss-news-feed-scraper"
            '''
          }
        }
      } 
    }
  }
}