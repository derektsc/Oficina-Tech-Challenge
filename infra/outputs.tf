output "cluster_name" {
  description = "Cluster Kubernetes local."
  value       = var.cluster_name
}

output "kube_context" {
  description = "Contexto kubectl apontando para o cluster."
  value       = "kind-${var.cluster_name}"
}

output "api_url" {
  description = "API exposta pelo NodePort mapeado no kind."
  value       = "http://localhost:30080"
}

output "mailpit_url" {
  description = "Caixa dos e-mails de status da OS."
  value       = "http://localhost:30025"
}
