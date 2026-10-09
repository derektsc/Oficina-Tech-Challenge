#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

kubectl apply -f "$ROOT/namespace.yaml"
kubectl apply -f "$ROOT/configmap.yaml"
kubectl apply -f "$ROOT/secret.yaml"
kubectl apply -f "$ROOT/postgres.yaml"
kubectl apply -f "$ROOT/mailpit.yaml"
kubectl -n oficina rollout status deployment/postgres --timeout=180s
kubectl apply -f "$ROOT/app.yaml"
kubectl apply -f "$ROOT/hpa.yaml"
kubectl apply -f "$ROOT/metrics-server.yaml"
kubectl -n oficina rollout status deployment/mailpit --timeout=180s
kubectl -n oficina rollout status deployment/oficina-api --timeout=300s
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s
kubectl -n oficina get deploy,svc,hpa,pvc
