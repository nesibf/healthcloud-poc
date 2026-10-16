# Incident response runbook
1. Declare severity, incident commander and communication channel; avoid PHI in tickets/logs.
2. Inspect `kubectl -n healthcloud get pods,deploy,hpa`, `kubectl -n healthcloud describe deploy healthcloud-api` and Cloud Logging.
3. Assess blast radius, user impact, latency and error metrics.
4. Mitigate: `kubectl -n healthcloud rollout undo deployment/healthcloud-api` if a rollout caused failure.
5. Escalate security incidents; preserve audit evidence with access controls.
6. Verify readiness and external synthetic checks; publish timeline and postmortem.
