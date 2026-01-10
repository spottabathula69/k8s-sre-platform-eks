#!/bin/bash
set -e

echo "====================================================="
echo " Deploying Platform Services (Helm)"
echo "====================================================="

# Ensure helm repos are added
echo "--> Adding Helm repositories..."
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 1. Metrics Server
echo "--> Installing Metrics Server..."
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --values platform/metrics-server/values.yaml \
  --wait

# 2. Ingress NGINX
echo "--> Installing Ingress NGINX..."
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --values platform/ingress-nginx/values.yaml \
  --wait

# 3. Sample App (Podinfo)
echo "--> Installing Sample App (Podinfo)..."
helm upgrade --install frontend podinfo/podinfo \
  --namespace default \
  --values platform/podinfo/values.yaml \
  --wait

# 4. Observability
echo "--> Installing Observability Stack..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values platform/observability/kube-prometheus-stack/values.yaml \
  --wait

echo "====================================================="
echo " Platform Deployment Complete"
echo "====================================================="

echo "Access URLs:"
kubectl get svc -n ingress-nginx
kubectl get svc -n monitoring
