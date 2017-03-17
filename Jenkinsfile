node('vultr-pro') {
    checkout scm
    stage('Build') {
        def dockerImg = docker.build 'test-jenkins:${env.BUILD_TAG}'
				dockerImg.run('-p 30000:30000')
    }
}