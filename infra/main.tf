resource "null_resource" "kind_cluster" {
  triggers = {
    cluster_name = var.cluster_name
    config_hash  = filesha256("${path.module}/kind-config.yaml")
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      if ! kind get clusters | grep -qx "${var.cluster_name}"; then
        kind create cluster --name "${var.cluster_name}" --config "${path.module}/kind-config.yaml"
      fi
      kubectl config use-context "kind-${var.cluster_name}"
    EOT
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["bash", "-c"]
    command     = "kind delete cluster --name '${self.triggers.cluster_name}' || true"
  }
}

resource "null_resource" "database" {
  depends_on = [null_resource.kind_cluster]

  triggers = {
    cluster  = null_resource.kind_cluster.id
    postgres = filesha256("${path.module}/../k8s/postgres.yaml")
    secret   = filesha256("${path.module}/../k8s/secret.yaml")
    namespace = filesha256("${path.module}/../k8s/namespace.yaml")
  }

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
      set -euo pipefail
      kubectl config use-context "kind-${var.cluster_name}"
      kubectl apply -f "${path.module}/../k8s/namespace.yaml"
      kubectl apply -f "${path.module}/../k8s/secret.yaml"
      kubectl apply -f "${path.module}/../k8s/postgres.yaml"
      kubectl -n oficina rollout status deployment/postgres --timeout=180s
    EOT
  }
}
