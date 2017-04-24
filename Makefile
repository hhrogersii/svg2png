SHELL := /bin/bash

.PHONY: minikube-init minikube-cleanup minikube-update minikube-status

minikube-init: minikube-cleanup
	k8s/minikube/deploy.sh init

minikube-cleanup:
	k8s/minikube/deploy.sh cleanup

minikube-update:
	k8s/minikube/deploy.sh update

minikube-status:
	k8s/minikube/deploy.sh status

