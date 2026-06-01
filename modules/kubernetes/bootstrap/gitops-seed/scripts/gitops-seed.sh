#!/usr/bin/env bash

set -e

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
export GITTYPE=$git_type
export VAULT_SERVER=$vault_server
export OTEL_SERVER=$otel_server
export OPERATOR=$cluster_operator
export PROVIDER=$cluster_provider
export CLUSTER_TYPE=$cluster_type
export CLUSTER_ENV=$cluster_env
export INFRA_BOOTSTRAP_RESILIENCE_ZONE=$infra_bootstrap_resilience_zone
export INGRESS_TYPE=$ingress_type
export INGRESS_SOURCE=$ingress_source

# Takes working dir and goes one back and into template
template_dir=$(dirname $0)/../template

checkout_dir=$(mktemp -d)

target_dir=$checkout_dir/clusters/$PROVIDER/$CLUSTER_NAME
remote_dir="/clusters/${PROVIDER}/${CLUSTER_NAME}"
git_url=${REPO}
git clone --depth 1 $git_url $checkout_dir

if [[ -f "${checkout_dir}/${remote_dir}/bootstrap/sync.yaml" ]];
then
   echo "bootstrap files already exists. Exit"
   exit 0
fi
find $template_dir -type f -exec $(dirname $0)/subst.sh $target_dir $template_dir {}  \;

pushd $checkout_dir
git add clusters/$PROVIDER/$CLUSTER_NAME
git commit -m "feat: :sparkles: Seeding cluster $PROVIDER/$CLUSTER_NAME"
git push 
popd

rm -rf $checkout_dir

