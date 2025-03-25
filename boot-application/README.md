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

# Boot / Root platform application

Once a Kubernetes cluster has been booted and ArgoCD installed, then everything else can be installed via ArgoCD. 

We use the ArgoCD "App of Apps" pattern. 

- create a new `platform` ArgoCD AppProject
- create a new `platform` ArgoCD application - this is the root app that will load all the other apps under [base](/base/) directory. 
 