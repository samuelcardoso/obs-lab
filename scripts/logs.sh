set -euo pipefail
kubectl logs deploy/chat-reply --all-containers=true --tail=200
echo "----"
POD=$(kubectl get pods -l app=chat-reply -o jsonpath='{.items[0].metadata.name}')
kubectl describe pod "$POD"
