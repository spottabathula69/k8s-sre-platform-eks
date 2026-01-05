# Production-Grade Kubernetes SRE Platform (EKS, Cost-Optimized)

A production-thinking GitHub portfolio project that demonstrates Staff/Principal-level SRE judgment:
- Fully reproducible infrastructure (Terraform)
- EKS + Helm-based deployments
- Observability (Prometheus, Grafana, Alertmanager)
- SRE controls: probes, HPA, PDB, rollouts
- Failure testing + runbooks + RCA templates
- Clean repo structure + CI checks

## Why this project
This repo is designed to mirror real SRE work: secure-by-default, measurable reliability,
clear operational playbooks, and explicitly documented tradeoffs (especially cost vs realism).

## High-level Architecture
- Terraform provisions: VPC, EKS, node group, IAM (IRSA/OIDC)
- Platform installs: Ingress + kube-prometheus-stack (Prometheus/Grafana/Alertmanager)
- App deployed via Helm chart with: probes, requests/limits, HPA, PDB, rollout strategy
- Ops: failure tests, runbooks, RCA templates

See: [docs/architecture.md](docs/architecture.md)

## Cost Strategy (AWS)
We optimize for the lowest reasonable cost while remaining interview-realistic.
See: [docs/cost-notes.md](docs/cost-notes.md)

## Repo Map
- `infra/` Terraform (reproducible + destroyable)
- `platform/` Helm charts + observability values + dashboards + alerts
- `ops/` runbooks, RCA template, failure tests
- `scripts/` helper scripts for common workflows
- `.github/workflows/` CI checks

## Quickstart (coming in next steps)
1) Provision infra
2) Configure kubectl
3) Install platform components (ingress, monitoring)
4) Deploy demo app (Helm)
5) Validate dashboards/alerts
6) Run failure tests
7) Destroy everything

## Optional future enhancements
- Datadog integration (optional / paid)
- Centralized logging (Loki/OpenSearch)
- GitOps (Argo CD) as an extension
- Private nodes + NAT Gateway “production-mode” variant
