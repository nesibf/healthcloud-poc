# Service level objectives (proposed, not measured)
- Availability target: 99.9% monthly for `/health/ready` through a user-facing endpoint.
- Latency target: 95% of successful API requests under 300 ms.
- Error rate: < 0.5% 5xx over a rolling 30-day window.
- Instrumentation: `/metrics` exposes Prometheus-format HTTP metrics. Scraping, Cloud Monitoring dashboards, uptime checks and alert policies are **not provisioned** by this scaffold.
- Alert proposal: 5xx rate > 2% for 5 min; no ready replicas for 2 min; CPU > 85% for 10 min.
