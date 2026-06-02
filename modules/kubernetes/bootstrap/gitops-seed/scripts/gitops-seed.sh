#!/usr/bin/env bash

set -eo pipefail

export REPO=$1
export CLUSTER_NAME=$cluster_simple_name
export REGION=$region
export ENV=$environment
export DNS=$cluster_dns
export RG=$resource_group
export TENANT=$tenant_id
export SUBSCRIPTION=$subscription_id
export DNS_CLIENT_ID=$dns_client_id
export DOLLAR='$'
export VAULT_SERVER=$vault_server
export OTEL_SERVER=$otel_server
export OPERATOR=$cluster_operator
export PROVIDER=$cluster_provider
export CLUSTER_TYPE=$cluster_type
export CLUSTER_ENV=$cluster_env
export INFRA_BOOTSTRAP_RESILIENCE_ZONE=$infra_bootstrap_resilience_zone
export INGRESS_TYPE=$ingress_type
export INGRESS_SOURCE=$ingress_source

gitops_username=$(echo "${netic_username}" | jq -Rr @uri)
gitops_token=$(echo "${netic_password}" | jq -Rr @uri)

template_dir=$(dirname "$0")/../template

checkout_dir=$(mktemp -d)
trap 'rm -rf "$checkout_dir"' EXIT

target_dir="$checkout_dir/clusters/$PROVIDER/$CLUSTER_NAME"
remote_dir="/clusters/${PROVIDER}/${CLUSTER_NAME}"

git clone --depth 1 "https://${gitops_username}:${gitops_token}@${REPO}" "$checkout_dir"

git -C "$checkout_dir" config user.email "terraform@netic.dk"
git -C "$checkout_dir" config user.name "Terraform"

if [[ -f "${checkout_dir}${remote_dir}/bootstrap/sync.yaml" ]]; then
  echo "bootstrap files already exists. Exit"
  exit 0
fi

find "$template_dir" -type f -exec "$(dirname "$0")/subst.sh" "$target_dir" "$template_dir" {} \;

git -C "$checkout_dir" add "clusters/$PROVIDER/$CLUSTER_NAME"
git -C "$checkout_dir" commit -m "feat: Seeding cluster $PROVIDER/$CLUSTER_NAME"
git -C "$checkout_dir" push "https://${gitops_username}:${gitops_token}@${REPO}"

