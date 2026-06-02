terraform {
  required_version = ">= 0.15"

  required_providers {
  }

}

resource "null_resource" "gitops_seed" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/gitops-seed.sh ${var.cluster_repo}"
    environment = {
      netic_username                    = var.netic_username
      netic_password                    = var.netic_password
      cluster_simple_name               = var.cluster_simple_name
      region                            = var.region
      environment                       = var.environment
      cluster_dns                       = var.cluster_dns
      resource_group                    = var.resource_group
      tenant_id                         = var.tenant_id
      subscription_id                   = var.subscription_id
      dns_client_id                     = var.dns_client_id
      vault_server                      = var.vault_server
      otel_server                       = var.otel_server
      cluster_operator                  = var.cluster_operator
      cluster_provider                  = var.cluster_provider
      cluster_type                      = var.cluster_type
      cluster_env                       = var.cluster_env
      infra_bootstrap_resilience_zone   = var.infra_bootstrap_resilience_zone
      ingress_type                      = var.ingress_type
      ingress_source                    = var.ingress_source
    }
  }
}
