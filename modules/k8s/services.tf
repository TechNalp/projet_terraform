resource "kubernetes_manifest" "services" {
  for_each = toset(var.service_manifests)

  manifest = merge(yamldecode(file("${var.path_to_manifests}/${each.value}")),{metadata = merge({namespace = "default"}, yamldecode(file("${var.path_to_manifests}/${each.value}")).metadata)})


}