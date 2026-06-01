#!/usr/bin/env bash

set -e

# Use the kubeconfig file written by Terraform — works for any cloud provider.
export KUBECONFIG="${kubeconfig_file}"

gitops_username=$(echo "${netic_username}" | jq -Rr @uri)
gitops_token=$(echo "${netic_password}" | jq -Rr @uri)

# --- Apply Flux / gotk components ---
checkout="$(pwd)/gotk-bootstrap-k8s"
git clone --depth 1 "https://${gitops_username}:${gitops_token}@git.netic.dk/scm/pd/gotk-bootstrap-k8s.git" "${checkout}"
pushd "${checkout}/gotk"
kubectl apply -f gotk-components.yaml
popd
rm -rf "${checkout}"

# --- Bootstrap the cluster GitOps repo ---
gh_url="$1"

if [ -n "${kubernetes_config_key}" ]; then
  echo "${kubernetes_config_key}" > ~/.ssh/id_ed25519_gitopsrepo
  cp ~/.ssh/config ~/.ssh/config.save
  cat <<EOF >> ~/.ssh/config
Host gitopsrepo
   HostName github.com
   IdentityFile ~/.ssh/id_ed25519_gitopsrepo
   User git
EOF
  chmod 600 ~/.ssh/*
  gh_url="${1/github.com/gitopsrepo}"
fi

checkout="$(pwd)/kubernetes-config"
git clone --depth 1 "${gh_url}" "${checkout}"

pushd "${checkout}/$2"
kubectl apply -k .
popd
rm -rf "${checkout}"

if [ -n "${kubernetes_config_key}" ]; then
  mv ~/.ssh/config.save ~/.ssh/config
fi
