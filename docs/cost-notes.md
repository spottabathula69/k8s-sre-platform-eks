# Cost Notes (AWS)

## Core principle
Minimize monthly spend while preserving real-world SRE patterns.

## Biggest cost traps to avoid
- NAT Gateway (can be a surprising fixed cost)
- Over-sized node groups
- Too many always-on add-ons

## Our baseline (cost-optimized)
- Small node group, minimal replicas
- 2 AZs for realism (but small footprint)
- Observability via open-source kube-prometheus-stack
- Keep logging simple (stdout + optional control plane logs)
- Everything destroyable with `terraform destroy`

## “Production-mode” upgrade path (documented tradeoff)
- Private subnets + NAT Gateway for private node egress
- More replicas + higher availability
- Dedicated logging backend (Loki/OpenSearch)
- More alert routes + paging (Opsgenie/PagerDuty)

## Optional paid tools
- Datadog (optional enhancement / paid SaaS)
  - Not required for this project
  - Can be added later to demonstrate SaaS observability experience
