# Security model (PoC)
- No PHI, real patient records or production credentials are permitted.
- Container runs as non-root, drops Linux capabilities and uses a read-only root filesystem.
- Cluster uses Workload Identity Federation for GKE; do not store long-lived service-account keys.
- Use least-privilege IAM and GitHub branch protection / mandatory review.
- Cloud Audit Logs should be reviewed and retention configured before real deployment.
- Pending: private nodes/control plane access strategy, NetworkPolicy enforcement, ingress TLS, policy admission, image signing, OIDC GitHub-to-GCP publishing, secret integration and vulnerability remediation process.
- GKE nodes require outbound access for image pulls and platform operations; this starter uses non-private nodes for simplicity.
