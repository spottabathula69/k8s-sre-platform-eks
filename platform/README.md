# Platform Components

This directory contains the Helm charts and configuration for the "Upper Stack" services running on EKS.

## Installed Components

| Component | Path | Description |
| :--- | :--- | :--- |
| **Metrics Server** | `metrics-server/` | Provides resource metrics (`kubectl top`) for HPA. |
| **Ingress NGINX** | `ingress-nginx/` | Ingress Controller exposed via Classic LoadBalancer (ELB). |
| **Podinfo** | `podinfo/` | Sample application for verifying HPA, PDB, and Ingress. |
| **Observability** | `observability/` | `kube-prometheus-stack` (Prometheus, Grafana, Alertmanager). |

## Deployment

All components are deployed via Helm. See the respective `values.yaml` in each subdirectory for configuration details.

### Common Commands

```bash
# Update Repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Install/Upgrade
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f platform/ingress-nginx/values.yaml
```
