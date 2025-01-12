resource "kubernetes_manifest" "pvc" {
  for_each = toset(var.pvc_manifests)
  
  manifest = merge(yamldecode(file("${var.path_to_manifests}/${each.value}")),{metadata = merge({namespace = "default"}, yamldecode(file("${var.path_to_manifests}/${each.value}")).metadata)})
}