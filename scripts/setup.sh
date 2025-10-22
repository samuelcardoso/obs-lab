# Setup

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack
kubectl get pods -n default   # (ou no namespace padrão do chart; por default é o current ns)
