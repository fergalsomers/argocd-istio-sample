# Copyright (c) [2024] Fergal Somers
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
#  
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

cd "$(dirname "$0")"

docker pull alpine

docker build . -t alpine_gettext

docker run -v $PWD:/wd \
  -e ISTIO_STATUS_NODE_PORT=$ISTIO_STATUS_NODE_PORT \
  -e ISTIO_HTTPS_NODE_PORT=$ISTIO_HTTPS_NODE_PORT \
  -e ISTIO_HTTP_NODE_PORT=$ISTIO_HTTP_NODE_PORT \
  -e ISTIO_HTTPS_PORT=$ISTIO_HTTPS_PORT \
  -e ISTIO_HTTP_PORT=$ISTIO_HTTP_PORT \
  alpine_gettext \
  sh -c "envsubst < /wd/istio-profile-template.yaml > /wd/istio-profile.yaml"

docker pull istio/istioctl:1.23.0

docker run -v $PWD/..:/wd \
 -e KUBECONFIG=/wd/kubeconfig \
    --network=host \
 istio/istioctl:1.23.0 \
 install -f /wd/istio/istio-profile.yaml -y

