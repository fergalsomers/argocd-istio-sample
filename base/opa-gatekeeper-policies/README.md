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

# opa-gatekeeper policies

This folder illustrates installing OPA-gatekeper community maintained policies, for example pod-security-policies. 

- https://open-policy-agent.github.io/gatekeeper-library/website/

They are organized into 2 argocd applications:
- policies templates
- constraints

Constraints are intended to be tailored to your use-case, I've included some take from the samples to illustrate. GIT clone the library repo and have a look at the samples as a a basis for configuration, e.g. 

```
git clone https://github.com/open-policy-agent/gatekeeper-library.git
```

# Notes

In order to get Argo Workflow to install, the following customizations of OPA policy were required. 

1. [mutation mustRunAsNonRoot](/base/opa-gatekeeper-policies/resources/policy/mutations/pod-security-policies/users/samples/mutation-mustRunAsNonRoot.yaml) - which set nonRoot (if unset) - excludes argo namespace  because httpbin and minio need to run as root. 
2. [constraint users](/base/opa-gatekeeper-policies/resources/constraints/users/constraint.yaml) - which requires non-roots user to be set (is a knock on the the previous issue). 