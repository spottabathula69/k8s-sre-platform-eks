# Architecture Overview

## Goals
- Demonstrate production-grade SRE thinking on EKS with minimal cost
- Make infra reproducible and fully destroyable
- Provide operational readiness: monitoring, alerts, runbooks, failure tests, RCA

## Components

### AWS
- VPC spanning 2 AZs
- EKS control plane (managed by AWS)
- Managed node group (small footprint; optionally Spot later)
- IAM + OIDC provider for IRSA (Kubernetes service accounts assume AWS roles)

### Kubernetes Platform
- Ingress controller: **NGINX** (Classic ELB)
  - Chosen for cost efficiency (avoids ALB per ingress) & portability.
- Observability: kube-prometheus-stack
  - Prometheus for scraping metrics
  - Grafana for dashboards
  - Alertmanager for warnings

### Application
- `podinfo` (Sample App) deployed via Helm
  - requests/limits
  - readiness/liveness probes
  - rolling update strategy
  - HPA (CPU-based initially)
  - PDB for safe disruption handling

### SRE Ops Artifacts
- Runbooks: common incident playbooks (5xx, latency, crashloops, HPA issues)
- Failure tests: controlled failure injection
- RCA template + sample incident

## Reliability Controls Included
- Health probes (liveness/readiness)
- HPA (scaling)
- PDB (availability during disruption)
- Deployment strategy (RollingUpdate, safe surge/unavailable settings)
- Alerts tied to SLO-like symptoms (e.g., error rate / latency)

## Analogy (simple)
Think of EKS as a restaurant:
- Terraform is the building blueprint + construction crew.
- Kubernetes is the floor manager that keeps enough staff and seats customers.
- Prometheus/Grafana are thermometers and dashboards showing issues early.
- Runbooks are the binder of procedures for when something breaks during rush hour.
