# HealthCloud Platform Engineering / SRE v2

## Architecture decisions
- Separate dev/staging/prod Terraform roots and state prefixes; prefer distinct GCP projects and IAM boundaries.
- GKE regional control plane, private nodes, Cloud NAT, Workload Identity; public control plane endpoint is retained for bootstrap and MUST be restricted/secured before real use.
- GitHub OIDC federation scoped to exact repository and main ref; no long-lived JSON keys.
- CI publishes SHA-tagged images. Argo CD is a separate, manually bootstrapped controller; it reconciles Git manifests. CI does NOT deploy directly.
- Staging/prod Argo CD Applications require explicit sync; dev autosyncs.
- GCP Monitoring dashboard and restart alert are examples, not an end-to-end SLO implementation.
- No EHR records or PHI; synthetic-only data.

## Bootstrap prerequisites
1. Create three GCP projects, enable billing, create secure per-environment GCS Terraform state buckets and restrict IAM. Enable versioning, retention, audit logs.
2. Bootstrap Terraform runner identity and its separate OIDC provider out of band (least privilege). The publisher identity in Terraform is NOT a Terraform-admin identity.
3. Set environment variables for GCP project, region, GitHub repository and on-call email. Copy backend.tf.example to backend.tf and configure real bucket.
4. Run `terraform init`, `terraform validate`, `terraform plan`; review cost and plan before manual apply.
5. Fetch GKE credentials securely; install Argo CD with reviewed pinned release and restricted access; apply GitOps Application after replacing repo URL and image placeholders.
6. Set GitHub Environment `dev` vars: GCP_WIF_PROVIDER, GCP_PUBLISHER_SA, GCP_REGION, GCP_PROJECT_ID. Protect staging/prod with reviewers.
7. Publish image on main; update Kustomize newTag via PR, allow Argo CD to reconcile.

## Threats and limits
- No Cloud SQL, Secret Manager, encryption-key rotation, data backup, or actual EHR data processing in this v2.
- No external HTTPS ingress, WAF, cert management, Argo CD SSO, Binary Authorization, signed provenance verification or complete network egress policies yet.
- GitHub Actions workflow actions use version tags for readability; pin reviewed commit SHAs before regulated deployment.
- Terraform provider compatibility and GCP quotas require validation against your account.
- The `terraform-plan.yml` workflow only executes live plan manually for dev; staging/prod plans need isolated credentials and approvals.
- DR workflow checks recovery assets weekly; an actual isolated Kubernetes restore drill is opt-in via `scripts/dr/validate-recovery.sh`. No data restore is claimed.

## Operational follow-ups
- Instrument RED metrics and SLO burn-rate alerts, managed collection of `/metrics`, logs-based error alerts.
- Add immutable signed images, image policy enforcement, private control-plane access and authorized networks.
- Add backup storage, backup schedule, restore verification, RPO/RTO evidence, periodic full environment recreation and failover exercises.
