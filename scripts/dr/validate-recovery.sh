#!/usr/bin/env bash
set -euo pipefail
# Exercise only a dedicated disposable DR cluster/namespace, never production.
: "${DR_CONTEXT:?Set DR_CONTEXT to dedicated test cluster context}"
: "${DR_NAMESPACE:=healthcloud-dr-test}"
if [[ "$DR_CONTEXT" != *dr* ]]; then echo 'Refusing context without dr in name' >&2; exit 1; fi
kubectl --context "$DR_CONTEXT" create namespace "$DR_NAMESPACE" --dry-run=client -o yaml | kubectl --context "$DR_CONTEXT" apply -f -
kubectl --context "$DR_CONTEXT" -n "$DR_NAMESPACE" apply -f k8s/dr/synthetic.yaml
kubectl --context "$DR_CONTEXT" -n "$DR_NAMESPACE" rollout status deployment/dr-synthetic --timeout=180s
kubectl --context "$DR_CONTEXT" -n "$DR_NAMESPACE" delete -f k8s/dr/synthetic.yaml --ignore-not-found
printf 'DR synthetic recovery test passed; this does not test data restore.
'
