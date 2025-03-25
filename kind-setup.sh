# Copyright [2024] Fergal Somers
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
# 
#        http://www.apache.org/licenses/LICENSE-2.0
# 
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#!/bin/sh

set -x

# Pre-requisites (see readme)

# Define some istio ports (k8 container port and K8 nodePort - note we expose the nodeports as hostports in Kind)
# This will allow you to access the ingress gateway via port 8080 (e.g. http://localhost:8080/productpage )

export ISTIO_HTTP_PORT=8081
export ISTIO_HTTP_NODE_PORT=31590
export ISTIO_HTTPS_PORT=8444
export ISTIO_HTTPS_NODE_PORT=31591
export ISTIO_STATUS_PORT=8222
export ISTIO_STATUS_NODE_PORT=31592

# Create a kind cluster with the necessary ports exposed for Istio
# Note that we also add a label to the control-plane node to allow the Istio ingress gateway to be scheduled on it
kind create cluster \
  --wait 120s \
  --config - <<EOF
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
    - containerPort: $ISTIO_HTTP_NODE_PORT  # Istio HTTP
      hostPort: $ISTIO_HTTP_PORT
      protocol: TCP
    - containerPort: $ISTIO_HTTPS_NODE_PORT # Istio HTTPS/TLS
      hostPort: $ISTIO_HTTPS_PORT
      protocol: TCP
    - containerPort: $ISTIO_STATUS_NODE_PORT # Istio status port
      hostPort: $ISTIO_STATUS_PORT
      protocol: TCP      
  
EOF


echo "Installing Istio.. " 

./istio/setup.sh

echo "... Istio installed" 

echo "Installing ArgoCD via Kustomize  ..." 

kubectl apply -k argocd

kubectl wait --for='jsonpath={.status.availableReplicas}'=1 deployment/argocd-server -n  argocd --timeout="60s"

echo "ArgoCD is running"

echo "Installing the boot application via Kustomize, ArgoCD will then load all the applications... " 

kubectl apply -k boot-application

echo "Boot application has been installed via ArgoCD" 

echo "... ArgoCD Installed. Check ArgoCD application statuses!"
