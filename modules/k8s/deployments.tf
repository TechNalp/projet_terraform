locals {
  full_registry_path = "${var.docker_registry_address}/${var.project_id}/terraform"
}


resource "kubernetes_manifest" "deployment" {
  for_each = toset(var.deployment_manifests)
  
  manifest = merge(
    yamldecode(
      file("${var.path_to_manifests}/${each.value}"
      )),
      {
        metadata = merge(
          {namespace = "default"}, yamldecode(file("${var.path_to_manifests}/${each.value}")).metadata
        )
        spec = yamldecode(
  can(regex(":", yamldecode(file("${var.path_to_manifests}/${each.value}")).spec.template.spec.containers[0].image)) # On utilise un replace pour remplacer le chemin de l'image du container par l'adresse correcte de l'image sur de dépot (il serait surement préférable de faire des merges mais la quantité de merge nécessaire était trop élévé)
  ? file("${var.path_to_manifests}/${each.value}")  # Si l'image contient déjà ":", on ne fait pas de remplacement
  : replace(
      file("${var.path_to_manifests}/${each.value}"), 
      "image: ${yamldecode(file("${var.path_to_manifests}/${each.value}")).spec.template.spec.containers[0].image}", 
      "image: ${local.full_registry_path}/${yamldecode(file("${var.path_to_manifests}/${each.value}")).spec.template.spec.containers[0].image}"
    )
).spec
      }
  )

  wait {
    fields = {
      "status.readyReplicas" = "^[1-9]\\d*$" # Force à attendre qu'il y ait au moins 1 réplicas d'actif avant de continuer l'execution du script terraform (on le fait surtout pour s'assurer que le job s'executera au bon moment)
    }
  }
  

}