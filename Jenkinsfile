def distros = ['all', 'ubuntu-18.04', 'ubuntu-20.04', 'ubuntu-22.04', 'ubuntu-24.04', 'rhel-9']
pipeline {
  parameters {
    choice(name: 'VERSION', choices: ['7.0.0'], description: 'Select Version')
    choice(name: 'TARGET', choices: ['all', 'ubuntu-18.04', 'ubuntu-20.04', 'ubuntu-22.04', 'ubuntu-24.04', 'rhel-9'], description: 'Select Target Distro')
  }
  agent {
    label 'smd_ibm'
  }
  options {
    ansiColor('xterm')
    buildDiscarder(logRotator(daysToKeepStr: '14', numToKeepStr: '30'))
    timeout(time: 8, unit: 'HOURS')
    timestamps()
  }
  libraries {
    lib('jenkins-library')
  }
  environment {
    DOCKER_BUILDKIT = '1'
    GITHUB_TOKEN = credentials('github_access_token_zabbix_s390x_deploy')
    GITHUB_REPOSITORY = 'pantovad/zabbix_s390x'
    GITHUB_SERVER_URL = 'https://github.com'
    msTeamsWebhookUrl = credentials('phoenix_systems_msteams_webhook')
  }
  stages {
    stage('Notify') {
      steps {
          notifyBuild('chat', 'STARTED', msTeamsWebhookUrl, "Job ${env.JOB_NAME} started")
      }
    }
    stage('Build packages') {
      environment {
        BUILD_DATE = sh(returnStdout: true, script: "date -u +'%Y-%m-%dT%H:%M:%SZ'").trim()
      }
      steps {
        withCredentials([string(credentialsId: 'github_access_token_zabbix_s390x_deploy', variable: 'GITHUB_TOKEN')]) {
          script{
            docker_image = docker.build("notag",
              " --build-arg VERSION=${params.VERSION}" +
              " --build-arg GITHUB_REPOSITORY=${env.GITHUB_REPOSITORY}" +
              " --build-arg GITHUB_SERVER_URL=${env.GITHUB_SERVER_URL}" +
              " --build-arg GITHUB_TOKEN=" + env.GITHUB_TOKEN +
              " --output type=tar,dest=/dev/null" +
              " --platform linux/s390x" +
              " --target " + params.TARGET +
              " --file Dockerfile_${env.VERSION} .")
          }
        }
      }
    }
  }
  post {
    success {
      notifyBuild('chat', 'SUCCESS', msTeamsWebhookUrl, "Job ${env.JOB_NAME} completed sucessfully")
    }
    failure {
      notifyBuild('chat', 'FAILURE', msTeamsWebhookUrl, "Job ${env.JOB_NAME} failed")
    }
    aborted {
      notifyBuild('chat', 'ABORTED', msTeamsWebhookUrl, "Job ${env.JOB_NAME} aborted")
    }
    fixed {
      notifyBuild('chat', 'FIXED', msTeamsWebhookUrl, "Job ${env.JOB_NAME} fixed")
    }
    unstable {
      notifyBuild('chat', 'UNSTABLE', msTeamsWebhookUrl, "Job ${env.JOB_NAME} is unstable")
    }
  }
}
