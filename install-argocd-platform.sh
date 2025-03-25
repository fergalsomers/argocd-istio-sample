
set -e

# This uses kubectl (built-in kustomize) to install the boot application as an ArgoCD project/application
# - ArgoCD will then take over and deploy the platform application.
# - The script waits for the platform application to be healthy before returning

kubectl apply -k boot-application

echo "ArgoCD will now load the platform application.."
echo "This may take up to 15 minutes.."
echo " - you can check the status of the application by running (in another terminal):"
echo " > kubectl get applications -n argocd -w"
echo ".. meanwhile waiting for the platform application to be healthy..." 

kubectl wait --for='jsonpath={.status.sync.status}'=Synced application/platform -n argocd --timeout="600s"

kubectl wait --for='jsonpath={.status.sync.status}'=Synced application --all -n argocd --timeout="900s"

kubectl wait --for='jsonpath={.status.health.status}'=Healthy application --all -n  argocd --timeout="900s"

echo "Platform is healthy and synced!" 
echo
echo "You can now access the ARGOCD application at http://localhost:8081/"
echo " - ArgoCD provides a GitOps platform for managing the platform"
echo " - you can use the ArgoCD UI to see all the applications and resources installed"
echo " - you will need to login with the username 'admin' and the password can be found by running:"
echo " > kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo

echo "You can also access Grafana UI at http://127.0.0.1:8081/grafana"
echo " - Grafana provide metrics observability for the platform"
echo " - you will need to login with the username 'admin' and the default password is also 'admin'"
echo " - you will be prompted to change the password on first login (of skip this step)"
echo " - All of the Kubernetes Mixin dashboards are available in the 'http://127.0.0.1:8081/dashboards' folder"

echo "You can also access Jaeger to view traces originating from the Ingress Gateway (i.e. your browser traffic). "
echo " - to setup local port-frorwarding to Jaeger, run:"
echo " > kubectl port-forward -n istio-system svc/tracing 8080:80 &"
echo 
echo " - you can then access Jaeger at http://localhost:8080/" to view traces in Jaeger UI

echo "Loading the platform via ArgoCD is complete. It took:"
