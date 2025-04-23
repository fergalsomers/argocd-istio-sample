<!---
Copyright (c) [2024] Fergal Somers
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# Context  <!-- omit from toc -->
This contains scripts that install [Istio](https://istio.io/) and [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) into a Kubernetes cluster. 

- For the purposes of this demo, it uses a local kubernetes [kind](https://kind.sigs.k8s.io/) cluster, so that you can install it on your laptop. 
- However, you can easily run the scripts on a remote Kuberentes cluster. 
- Istio is used to provide a service mesh. This provides secure TLS communication between pods (east-west comms). It is also used to configure an ingress gateway to allow routing of inbound requests. In this demo to access ArgoCD and Grafana directly from your laptop's browser. 
- ArgoCD is used to automate installation of some standard useful platform software via GITOps (Prometheus for monitoring, Grafana for observability, OPA Gateway for policy enforcement)

The purpose of this demo is to illustrate that once you have a K8 cluster and ArgoCD installed, you can easily cookie-cutter a platform ready for developers to use. 

*Contents*

- [Pre-requisites](#pre-requisites)
- [How to install](#how-to-install)
- [To view ArgoCD UI](#to-view-argocd-ui)
- [To view Grafana UI](#to-view-grafana-ui)
- [To view Jaeger UI](#to-view-jaeger-ui)
- [To clean up](#to-clean-up)
- [To Do](#to-do)
- [Notes](#notes)
  - [Installing kube-prometheus community setup.](#installing-kube-prometheus-community-setup)


# Pre-requisites

1. Install [Docker](https://docs.docker.com/engine/install/)
1. Install [kind](https://kind.sigs.k8s.io/) - for mac "brew install kind"
1. Install [kubectl](https://kubernetes.io/docs/reference/kubectl/) - for mac "brew install kubectl"
1. Install [git](https://git-scm.com/) - git comes with Xcode on mac. 
2. Make - comes pre-installed on mac with Xcode, but you can always upgrade it to the latest! `xcode-select --install`

# How to install

Clone the repo and 

```
git clone https://github.com/fergalsomers/argocd-istio-sample
cd argocd-istio-sample
make platform
```

This can take 5-10 minutes - it is doing quite a lot: 


1. Create a kind cluster call `argocd-istio-sample`
2. Create a kubeconfig in argocd-istio-sample directory (this allows you to use kubectl to access your cluster)
3. Install Istio service mesh
4. Install ArgoCD in `argocd` namespace. 
5. Install the `platform` ArgoCD project and applications - see [boot-application](/boot-application/). ArgoCD will then take over loading all the various parts of the platform from [base](/base/) via GITOps. 

This base platform contains:

- [OPA Gatekeeper](https://kubernetes.io/blog/2019/08/06/opa-gatekeeper-policy-and-governance-for-kubernetes/) - policy enforcement for kubernetes
- [Kube-prometheus monitoring stack](https://github.com/prometheus-operator/kube-prometheus). 
   This installs everything you need for a basic metrics stack including:
  - The [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
  - Highly available [Prometheus](https://prometheus.io/) - for metric storage and querying
  - Highly available [Alertmanager](https://github.com/prometheus/alertmanager) - for alerting
  - [Prometheus node-exporter](https://github.com/prometheus/node_exporter) - for getting node level metrics in K8
  - [Prometheus blackbox-exporter](https://github.com/prometheus/blackbox_exporter) - for pinging arbitrary services
  - [Prometheus Adapter for Kubernetes Metrics APIs](https://github.com/kubernetes-sigs/prometheus-adapter) - for getting K8-level metrics
  - [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) - community recommended dashboards for grafana
  - [Grafana](https://grafana.com/) - Grafana UI for metrics
- [Jaeger](https://www.jaegertracing.io/) - for tracing, integrated with Istio for automated tracing collection. 
  
# To view ArgoCD UI

First get the password for the ArgoCD `admin` user, run:

```
> kubectl -n platform get secret platform-argocd-cluster \
    -o jsonpath='{.data.admin\.password}' | base64 -d
```

Then click on following URL in your browser : [http://localhost:8081/](http://localhost:8081)
- Istio has been configured to listen on the 8081 is a host port exposed by the Kind cluster. 


Alternatively, you can use kubectl to port-forward directly to the grafana service, run :

```
> nohup kubectl port-forward -n platform service/platform-argocd-server 8080:80 &
```

and then click on following URL in your browser : http://localhost:8080/


# To view Grafana UI

Simply click on following URL in your browser : [http://127.0.0.1:8081/](http://127.0.0.1:8081)

- Use the default grafana password admin/admin - you are prompted to change this on login.

Alternatively,  you can use kubectl to port-forward directly to the grafana service, run : 

```bash
> kubectl port-forward -n monitoring service/grafana 3000 &
```

and then on following URL in your browser : http://localhost:3000/

# To view Jaeger UI

You can access the Jaeger UI to view traces originating from the Ingress Gateway (i.e. your browser traffic from the previous steps).
You will need to run port-forwarding

```bash
 > kubectl port-forward -n istio-system svc/tracing 8080:80 &
 ```

 Then then click on the following URL in your browser http://localhost:8080/

# To clean up

kind delete cluster --name=argocd-istio-demo

# To Do

- Add Loki for log collection and browsing in Grafana


# Notes

## Installing kube-prometheus community setup. 

Istio gateways match on hostnames, and we have bound ArgoCD and Grafana virtual services to `localhost` and `127.0.0.1` to allow them to both be served. A little hack-y admittedly but it works for laptop based access. Obviously a real setup would have proper DNS sub-domains. 