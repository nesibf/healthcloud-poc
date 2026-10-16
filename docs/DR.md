# Disaster recovery — exercise plan, not an implemented backup
- This starter has no persistent application data. Cloud SQL and Secret Manager are future phases.
- Proposed RTO: 4 hours; proposed RPO: 24 hours (not validated).
- Terraform state must be protected in a remote GCS backend with versioning, access restrictions and recovery testing before team use.
- Back up Git repository, immutable image digests, Terraform state and relevant cluster configuration.
- Test: recreate infrastructure in a separate project; redeploy pinned image; validate endpoints and alerts.
- For future Cloud SQL: automated backups, PITR, regional recovery design and quarterly restore drills.
- Record restore durations and revise RTO/RPO only after successful tests.
