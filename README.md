# HealthCloud Platform — Production



**Demo only. No real patient data. No production security or availability guarantee.**

GCP / GKE / Terraform modules / GitHub OIDC / GitHub Actions / Argo CD GitOps / Monitoring / DR readiness.

See [Production architecture, bootstrap and limitations](docs/PRODUCTION.md).

## Directories
- `api/`: FastAPI app, health checks, metrics, unit tests, non-root image
- `infra/modules/`: network (VPC, NAT), GKE, identity federation, monitoring
- `infra/environments/{dev,staging,prod}`: independent Terraform roots; copy `terraform.tfvars.example`
- `k8s/overlays/{dev,staging,prod}`: immutable image tag promotion via PR
- `gitops/applications/`: Argo CD Applications (bootstrap separately)
- `.github/workflows/`: CI, image publish, validation/plan, weekly offline DR readiness
- `scripts/dr/`: isolated live DR smoke drill (manual, guarded)

## Validate locally
```bash
python3 -m venv .venv && . .venv/bin/activate
pip install -r api/requirements-dev.txt
PYTHONPATH=api pytest -q api/tests
terraform -chdir=infra/environments/dev init -backend=false
terraform -chdir=infra/environments/dev validate
kubectl kustomize k8s/overlays/dev >/tmp/healthcloud-dev.yaml
```

**Terraform apply creates billable GCP resources.** Review plans, budgets, security, GCP IAM and quotas first.
