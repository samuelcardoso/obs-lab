# OBS Lab — Observabilidade (Prometheus + Grafana em Kubernetes)

Este lab adiciona **observabilidade** à aplicação `chat-reply` em um cluster local (minikube), expondo métricas **Prometheus** e visualizando no **Grafana**.

A app já expõe:
- `GET /metrics` em formato Prometheus (via `prom-client`);
- `GET /healthz` e `GET /readyz` para liveness/readiness;
- `POST /reply` como endpoint funcional.

## Pré-requisitos
- Docker
- kubectl
- minikube (com cluster iniciado)
- Helm 3

> Dica: o WS2 (Kubernetes) já cobre a criação do cluster. Se necessário, rode:  
> `minikube start && minikube addons enable ingress`

## Estrutura
- `app/` (Node.js com métricas Prometheus)
- `k8s/deployment.yaml`, `k8s/service.yaml`, `k8s/servicemonitor.yaml` (+ `ingress.yaml` opcional)
- `scripts/setup.sh` — instala kube-prometheus-stack
- `scripts/apply.sh` — build da imagem local + aplica manifests
- `scripts/grafana.sh` — port-forward do Grafana (:3001)
- `scripts/logs.sh` — inspeção de logs e describe do Pod

## Passo a passo

### 1) Instalar o stack de observabilidade
Instala Prometheus, Alertmanager e Grafana via Helm.
```bash
cd obs-lab
./scripts/setup.sh
```
> Aguarde os Pods ficarem `Running`:
```bash
kubectl get pods
```

### 2) Build & deploy da app com métricas
```bash
./scripts/apply.sh
```
Este script:
- Builda a imagem `chat-reply:0.1.0` a partir de `app/`;
- Faz `minikube image load` da imagem para o cluster;
- Aplica `Deployment`, `Service` e `ServiceMonitor`.

> **Ingress é opcional**. Descomente a linha no `scripts/apply.sh` se quiser acessar `POST /reply` por host (ex.: `chat.local`).

### 3) Abrir Grafana
```bash
./scripts/grafana.sh
```
- Faz port-forward do serviço Grafana para `http://localhost:3001`.
- As credenciais padrão podem ser obtidas pelos segredos (comandos no script).

### 4) Validar métricas
- Acesse `http://localhost:3001` (Grafana).
- O Prometheus já deve estar coletando da app via `ServiceMonitor`.
- No Prometheus (ou via Grafana Explore), procure por:
  - `http_requests_total` (counter por rota/método/código)
- Gere tráfego para a app (via Service/Ingress) e veja os contadores subirem.

## Endpoints da app
- `GET /healthz` — liveness
- `GET /readyz` — readiness
- `POST /reply` — exemplo funcional
- `GET /metrics` — métricas Prometheus

## Solução de problemas
- **ServiceMonitor CRD ausente**: rode `./scripts/setup.sh` antes de `./scripts/apply.sh`.
- **Sem dados no Prometheus**: confirme labels e porta:
  - `Service` tem `labels: { app: chat-reply }` e porta nomeada `http`.
  - `ServiceMonitor` seleciona `app: chat-reply` e `endpoints.port: http`.
- **Imagem não encontrada**: rode `docker build ...` e `minikube image load` (o `apply.sh` já faz).
- **Grafana não abre**: certifique-se do port-forward ativo e repita `./scripts/grafana.sh`.