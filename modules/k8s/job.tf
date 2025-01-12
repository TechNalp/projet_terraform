resource "kubernetes_manifest" "job" {

for_each = toset(var.job_manifests)

manifest = merge(
    yamldecode(
      file("${var.path_to_manifests}/${each.value}"
      )),
      {
        metadata = merge(
          {namespace = "default"}, yamldecode(file("${var.path_to_manifests}/${each.value}")).metadata
        )
        spec = yamldecode(
  can(regex(":", yamldecode(file("${var.path_to_manifests}/${each.value}")).spec.template.spec.containers[0].image)) 
  ? file("${var.path_to_manifests}/${each.value}")  # Si l'image contient déjà ":", on ne fait pas de remplacement
  : replace(
      file("${var.path_to_manifests}/${each.value}"), 
      "image: ${yamldecode(file("${var.path_to_manifests}/${each.value}")).spec.template.spec.containers[0].image}", 
      "image: ${local.full_registry_path}/${yamldecode(file("${var.path_to_manifests}/${each.value}")).spec.template.spec.containers[0].image}"
    )
).spec
      }
  )

depends_on = [ kubernetes_manifest.deployment, kubernetes_manifest.services, kubernetes_manifest.pvc ]
}