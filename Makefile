# Simple makefile for creating cluster


export ISTIO_HTTP_PORT ?= 8081
export ISTIO_HTTP_NODE_PORT ?= 31590
export ISTIO_HTTPS_PORT ?= 8444
export ISTIO_HTTPS_NODE_PORT ?=31591
export ISTIO_STATUS_PORT ?= 8222
export ISTIO_STATUS_NODE_PORT ?= 31592

define kindconfig
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: argocd-istio-sample
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: $(ISTIO_HTTP_NODE_PORT)  # Istio HTTP
        hostPort: $(ISTIO_HTTP_PORT)
        protocol: TCP
      - containerPort: $(ISTIO_HTTPS_NODE_PORT) # Istio HTTPS/TLS
        hostPort: $(ISTIO_HTTPS_PORT)
        protocol: TCP
      - containerPort: $(ISTIO_STATUS_NODE_PORT) # Istio status port
        hostPort: $(ISTIO_STATUS_PORT)
        protocol: TCP  
endef
export kindconfig

kind:
	@echo "Creating Kind cluster..."
	@echo "$$kindconfig" > kind-config.yaml
	kind create cluster \
  	--wait 120s \
 	--config kind-config.yaml
	@echo ">> Kind cluster created"

.PHONY: istio
istio:
	@echo "Installing Istio..."
	./istio/setup.sh
	@echo ">> Istio installed" 


argocd: argocd-kustomize

argocd-kustomize:
	@echo "Installing ArgoCD via Kustomize..."
	kubectl apply -k argocd
	kubectl wait --for='jsonpath={.status.availableReplicas}'=1 deployment/argocd-server -n  argocd --timeout="60s"
	@echo "ArgoCD is running!"

boot-platform:
	time ./install-argocd-platform.sh

platform:	kind istio argocd boot-platform

clean:
	@echo "Deleting Kind cluster..."
	kind delete cluster --name argocd-istio-sample
