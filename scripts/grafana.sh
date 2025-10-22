set -euo pipefail
echo "Serviço Grafana:"
kubectl get svc | grep grafana || true
echo
echo "Fazendo port-forward em :3001"
kubectl port-forward svc/monitoring-grafana 3001:80
# Acesse http://localhost:3001
# Credenciais: consulte o secret se necessário:
# kubectl get secret -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].data.admin-user}' | base64 -d; echo
# kubectl get secret -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].data.admin-password}' | base64 -d; echo
