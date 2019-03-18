pipeline {
  agent any

  options {
    buildDiscarder(logRotator(numToKeepStr:'2'))
    disableConcurrentBuilds()
  }

  tools {
    // see https://wiki.eclipse.org/Jenkins#Jenkins_configuration_and_tools_.28clustered_infra.29
    maven 'apache-maven-latest'
    jdk 'oracle-jdk8-latest'
  }
  
  // https://jenkins.io/doc/book/pipeline/syntax/#triggers
  triggers {
    cron('H H(2-6) * * 1-5') // once a day in the night on weekdays
  }
  
  // Build stages
  stages {
    stage('Aggregate Targets') {
      steps {
          configFileProvider([configFile(fileId: '7a78c736-d3f8-45e0-8e69-bf07c27b97ff', variable: 'MAVEN_SETTINGS')]) {
            dir ('releng/platform-targets/oxygen') {
               sh "mvn  -s ${MAVEN_SETTINGS} --batch-mode"
            }
            dir ('releng/platform-targets/2019-03') {
               sh "mvn  -s ${MAVEN_SETTINGS} --batch-mode"
            }
          }
      }
    }
  }

  post {
    success {
      archiveArtifacts artifacts: '*/target/repository/final/**'
    }
    changed {
      script {
        if (env.SLACK_URL?.trim() && env.SLACK_CHANNEL?.trim() && env.SLACK_TOKEN?.trim()) {
          def envName = ''
          if (env.JENKINS_URL.contains('ci.eclipse.org/xtext')) {
            envName = ' (JIPP)'
          } else if (env.JENKINS_URL.contains('jenkins.eclipse.org/xtext')) {
            envName = ' (CBI)'
          } else if (env.JENKINS_URL.contains('typefox.io')) {
            envName = ' (TF)'
          }
          
          def curResult = currentBuild.currentResult
          def color = '#00FF00'
          if (curResult == 'SUCCESS' && currentBuild.previousBuild != null) {
            curResult = 'FIXED'
          } else if (curResult == 'UNSTABLE') {
            color = '#FFFF00'
          } else if (curResult == 'FAILURE') {
            color = '#FF0000'
          }
          
          slackSend message: "${curResult}: <${env.BUILD_URL}|${env.JOB_NAME}#${env.BUILD_NUMBER}${envName}>", botUser: true, color: "${color}", baseUrl: env.SLACK_URL, channel: env.SLACK_CHANNEL, token: env.SLACK_TOKEN
        }
      }
    }
  }
}
