resource "kubernetes_namespace" "principal" {
  metadata {
        name = var.namespace_name
  }
}