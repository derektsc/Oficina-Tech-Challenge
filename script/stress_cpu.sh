#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-oficina}"
SECONDS_TO_RUN="${SECONDS_TO_RUN:-180}"

echo "Gerando CPU em oficina-api por ${SECONDS_TO_RUN}s para o HPA observar."
kubectl -n "$NAMESPACE" exec deploy/oficina-api -- \
  ruby -e "require 'openssl'; pids = 4.times.map { fork { loop { OpenSSL::Digest::SHA256.hexdigest(rand.to_s) } } }; sleep ${SECONDS_TO_RUN}; pids.each { |pid| Process.kill('TERM', pid) rescue nil }"

echo "Acompanhe com: kubectl -n ${NAMESPACE} get hpa oficina-api -w"
