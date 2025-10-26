set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# (Re)build e load no minikube, caso tenha mudado a app:
docker build -t chat-reply:0.1.0 "$REPO_ROOT/app"
minikube image load chat-reply:0.1.0

kubectl apply -f "$REPO_ROOT/k8s/deployment.yaml"
kubectl apply -f "$REPO_ROOT/k8s/service.yaml"
kubectl apply -f "$REPO_ROOT/k8s/servicemonitor.yaml"

# ingress é opcional; descomente se quiser:
# kubectl apply -f "$REPO_ROOT/k8s/ingress.yaml"

kubectl get pods,svc
