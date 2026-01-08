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

### AWS Profile

Infrastructure is provisioned using a **dedicated IAM user and CLI profile** to isolate blast radius.

```bash
export AWS_PROFILE=sre-platform
export AWS_REGION=us-west-2
aws sts get-caller-identity
```

---

## Quickstart

See: [docs/bootstrap.md](docs/bootstrap.md)

