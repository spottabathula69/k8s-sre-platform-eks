# Production-Grade Kubernetes SRE Platform (EKS, Cost-Optimized)

A production-thinking GitHub portfolio project that demonstrates **Staff / Principal-level SRE judgment**:

- Fully reproducible infrastructure (Terraform)
- EKS + Helm-based deployments
- Observability (Prometheus, Grafana, Alertmanager)
- SRE controls: probes, HPA, PDB, controlled rollouts
- Failure testing + runbooks + RCA templates
- Explicit tradeoffs: cost vs realism vs operability

---

## Why this project

This repository is designed to mirror **real SRE platform work**, not a demo cluster.

The focus is on:
- Clean bootstrap and teardown
- Predictable operational behavior
- Clear validation points
- Explicit documentation of design decisions and tradeoffs

---

## High-level Architecture

- **Terraform provisions**:
  - VPC (cost-optimized, public subnets)
  - EKS control plane
  - Managed node groups
  - IAM roles (OIDC / IRSA)

- **Platform installs**:
  - Ingress controller
  - kube-prometheus-stack (Prometheus, Grafana, Alertmanager)

- **Workloads**:
  - Helm-deployed demo app
  - Probes, requests/limits, HPA, PDB
  - Controlled rollout strategies

- **Operations**:
  - Failure tests
  - Runbooks
  - RCA templates

See: [docs/architecture.md](docs/architecture.md)

---

## Cost Strategy (AWS)

The platform is intentionally optimized for **low cost while remaining interview-realistic**:

- No NAT Gateway (public subnets only for initial build)
- Minimal node count and instance size
- All infrastructure is fully destroyable

Tradeoffs and future “production-mode” variants are documented.

See: [docs/cost-notes.md](docs/cost-notes.md)

---

## Repo Map

- `infra/` — Terraform (reproducible + destroyable)
- `platform/` — Helm charts, monitoring values, dashboards, alerts
- `ops/` — runbooks, RCA templates, failure tests
- `scripts/` — helper scripts
- `.github/workflows/` — CI checks

---

## Prerequisites

- AWS account (region: `us-west-2`)
- AWS CLI v2
- Terraform
- kubectl

### AWS account setup (required)

This project assumes you use a dedicated AWS CLI named profile:

[`docs/aws_account_setup.md`](docs/aws_account_setup.md)

## Quick Start
1.  **Deploy Infrastructure**: `terraform apply` in `infra/envs/dev`
2.  **Install Platform**: See `platform/` READMEs.
3.  **Operations**:
    *   **Monitor**: Grafana (admin/admin)
    *   **Debug**: See [Runbooks](docs/runbooks/)
    *   **Incident**: Use [RCA Template](docs/templates/rca.md)
