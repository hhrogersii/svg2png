SHELL := /bin/bash

.PHONY: phantomjs-server docker-build docker-run minikube-init minikube-cleanup minikube-update minikube-status

phantomjs-server:
	phantomjs service/service.js

docker-build:
	docker build -t report2chart-dock .

docker-run:
	docker run -p 8910:8910 report2chart-dock

# don't forget to minikube start

minikube-init: minikube-cleanup
	k8s/minikube/deploy.sh init

minikube-cleanup:
	k8s/minikube/deploy.sh cleanup

minikube-update:
	k8s/minikube/deploy.sh update

minikube-status:
	k8s/minikube/deploy.sh status

