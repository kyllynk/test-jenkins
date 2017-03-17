node("vultr-pro"){
	sh 'git pull; docker build -t test-jenkins .; docker run -d -p 30000:30000 test-jenkins'
}