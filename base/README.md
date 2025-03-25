# Base

This directory contains the base applications which make up the platform (for example OPA gatekeeeper and prometheus).

- For operators, where appropriate, we use Operator Lifecycle Manager (OLM) to install the operators (e.g prometheus). 
- For other operators (e.g. OPA) - we install directly (either via Kustomize/GIT or Helm). 
- We attempt to use community managed best-practice configurations where available. 

See the [kustomization.yaml](/base/kustomization.yaml) for details of what is included.
