#!/usr/bin/env bash

set -eo pipefail

# 1. Skriv den dynamiske kubeconfig til en midlertidig fil på maskinen/runneren
export KUBECONFIG="$(pwd)/kvm-kubeconfig.tmp"
echo "$KUBECONFIG_RAW" > "$KUBECONFIG"
chmod 600 "$KUBECONFIG"

# Sørg for at rydde kubeconfig-filen op når scriptet afsluttes (uanset om det fejler eller lykkes)
checkout_gotk="$(pwd)/gotk-bootstrap-k8s"
checkout_config="$(pwd)/kubernetes-config"
trap 'rm -f "$KUBECONFIG"; rm -rf "$checkout_gotk" "$checkout_config"' EXIT

gitops_username=$(echo "${netic_username}" | jq -Rr @uri)
gitops_token=$(echo "${netic_password}" | jq -Rr @uri)

# --- Apply Flux / gotk components ---
git clone --depth 1 "https://${gitops_username}:${gitops_token}@git.netic.dk/scm/pd/gotk-bootstrap-k8s.git" "${checkout_gotk}"
pushd "${checkout_gotk}/gotk"
{
  echo "=== GOTK DEBUG $(date) ==="
  echo "perl test: $(echo '${foo:=bar}' | perl -pe 's/\$\{(\w+)(?::=([^}]*))?\}/$ENV{$1} \/\/ $2 \/\/ ""/ge')"
  perl -pe 's/\$\{(\w+)(?::=([^}]*))?\}/$ENV{$1} \/\/ $2 \/\/ ""/ge' gotk-components.yaml > /tmp/gotk-substituted.yaml
  echo "memory linje: $(grep 'source_controller_mem\|memory:' /tmp/gotk-substituted.yaml | head -3)"
} > /tmp/gotk-debug.log 2>&1
kubectl apply --server-side --force-conflicts -f /tmp/gotk-substituted.yaml
popd

# --- Bootstrap the cluster GitOps repo ---
git clone --depth 1 "https://${gitops_username}:${gitops_token}@$1" "${checkout_config}"

pushd "${checkout_config}/$2"
kubectl kustomize . | perl -pe 's/\$\{(\w+)(?::=([^}]*))?\}/$ENV{$1} \/\/ $2 \/\/ ""/ge' | kubectl apply --server-side --force-conflicts -f -
popd