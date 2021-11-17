SHELL = /bin/bash

FORCE:

minikube-start:
	minikube start

setup:
	kubectl config use-context minikube
	- kubectl create namespace grafana-dashboard-operator
	- kubectl create namespace monitoring
	- kubectl create namespace metacontroller
	- helm upgrade --namespace monitoring --install --wait kube-prometheus-stack --repo https://prometheus-community.github.io/helm-charts kube-prometheus-stack
	kubectl wait deployments.apps/kube-prometheus-stack-grafana --namespace monitoring --for condition=available --timeout=0s --request-timeout='0'
	- kubectl apply -n metacontroller -k https://github.com/metacontroller/metacontroller/manifests/production
	sleep 120 # Allow time for Grafana to kick in - next thing we're calling it's API...
	- kubectl delete secret --namespace grafana-dashboard-operator grafana-api
	- kubectl --namespace grafana-dashboard-operator create secret generic grafana-api \
		--from-literal=token=$(shell \
		 	echo "curl -X POST -H \"Content-Type: application/json\" -d '{\"name\":\"apikey$${RANDOM}\", \"role\": \"Admin\"}' http://admin:prom-operator@kube-prometheus-stack-grafana/api/auth/keys 2>/dev/null ; echo" | \
		 	kubectl run -i --rm -n monitoring --image curlimages/curl curl$${RANDOM} -- sh 2>/dev/null | grep -v -e "pod .* deleted" | yq eval '.key' -)

build_number: FORCE
	$(eval BUILD_NUMBER=$(shell od -An -N10 -i /dev/urandom | tr -d ' -' ))

update: FORCE build_number
	- mkdir build
	kubectl config use-context minikube
	eval $$(minikube docker-env) && docker build ./controller -t grafana-dashboard-operator:${BUILD_NUMBER}

	docker run --mount "type=bind,src=$$PWD/manifests,dst=/src" ghcr.io/srfrnk/k8s-jsonnet-manifest-packager:latest -- /src \
		--tla-str 'imagePrefix=' \
		--tla-str 'buildNumber=${BUILD_NUMBER}' \
		> build/manifests.yaml

	kubectl -n grafana-dashboard-operator apply -f build/manifests.yaml

pf-grafana:
	kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

deploy-examples:
	kubectl apply -f ./examples
