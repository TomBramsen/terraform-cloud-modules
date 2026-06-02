terraform {
  required_version = ">= 1.3"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}

# Write kubeconfig to a temp file so kubectl can use it directly.
# Marked sensitive so Terraform never prints the content in logs.
resource "local_sensitive_file" "kubeconfig" {
  content         = var.kubeconfig
  filename        = "${path.cwd}/.kubeconfig-bootstrap"
  file_permission = "0600"
}

# Wait until the node pool is actually ready before trying to apply anything.
# Uses kubectl (works for any provider) instead of `az aks command invoke`.
resource "null_resource" "wait_for_workers" {
  provisioner "local-exec" {
    command = <<-EOT
      sleep 60
      kubectl --kubeconfig=${local_sensitive_file.kubeconfig.filename} \
        wait --for=condition=Ready nodes --all --timeout=300s
    EOT
  }

  depends_on = [local_sensitive_file.kubeconfig]
}

# Create the netic-gitops-system namespace + git-auth secrets on the cluster.
resource "local_file" "netic_git_auth" {
  for_each = var.git_auth

  content = <<-EOF
    ---
    apiVersion: v1
    kind: Namespace
    metadata:
      labels:
        name: netic-gitops-system
      name: netic-gitops-system
    ---
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${each.key}-git-auth
      namespace: netic-gitops-system
    type: Opaque
    data:
    %{ for key, value in each.value ~}
      ${key}: ${base64encode(value)}
    %{ endfor ~}
  EOF

  filename        = "${path.cwd}/${each.key}-git-auth.yaml"
  file_permission = "0600"

  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${local_sensitive_file.kubeconfig.filename} apply -f ${path.cwd}/${each.key}-git-auth.yaml"
  }

  depends_on = [null_resource.wait_for_workers]
}

resource "null_resource" "gitops_bootstrap" {
  provisioner "local-exec" {
    command     = "${path.module}/scripts/gitops-bootstrap.sh ${var.cluster_repo} ${var.bootstrap_path}"
    working_dir = path.cwd

    environment = {
      # Vi dumper rå-stringen direkte ind i miljøvariablen her
      KUBECONFIG_RAW        = var.kubeconfig
      netic_username        = var.git_auth["netic"].username
      netic_password        = var.git_auth["netic"].password
      kubernetes_config_key = try(var.git_auth["kubernetes-config"].identity, "")
    }
  }
  depends_on = [null_resource.wait_for_workers]
}
