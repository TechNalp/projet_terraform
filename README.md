# PROJET TERRAFORM

#### _Louan BELICAUD et Mathis PLANCHET_

### Structure du projet

Le projet est séparé en 3 dossiers:

- Part 1: Uniquement docker en local

- Part 2.1: Publication des images docker sur un dépot distant et utilisation de k8s (y compris pour redis)

- Part 2.2: Publication des images docker sur un dépot distant et utilisation de k8s (redis étant sur une vm séparée)

Nous avons utilisé des modules terraform pour nous permettre de facilement réutiliser du code entre les parties.

Les modules que nous avons créés:

- docker_image: Chargé du build et de l'envoi des des images docker sur des dépots distant.

- docker: Chargé de créer les conteneurs docker en local

- gcp: Chargé de créer le cluster k8s

- redis_vm: Chargé de créer et de configurer une vm pour redis

- k8s: Chargé de créer les deployment/service/pvc/job dans un cluster k8s

### Prérequis:

> Pour tout ce qui concerne GCP nous supposons que vous avez déjà configuré un projet, et que vous avez exporté vos credientals dans un fichier json.

> Nous supposons que vous avez également activé les services nécessaire (compute engine/kubernetes engine/ artifact registry)

> Nous supposons que vous avez déjà un artifact registry qui stockera les images docker (il faut que le nom du dépot soit `terraform`)

> Nous supposons que vous avez créer un compte de service avec les bonnes permisssions (nottament `Service Account Token Creator`)

## Pour la partie 1 (docker en local):

> Bien avoir docker de lancé

> Faire `terraform init`

> Puis `terraform apply`

Améliorations éffectué:

- [x] Les apply vont rebuild les images si le code du service à changé

## Pour la partie 2.1 (k8s sur gcp avec redis en pod):

> Ce mettre dans le dossier part2.1

> Faire `terraform init`

> Ouvrir le fichier part2.1/terraform.tfvars et indiqué les informations spécifique à votre projet:

> - `project_id`: l'id du projet sur gcp
> - `region` = la région du projet sur gcp
> - `zone` = la zone du projet sur gcp
> - `private_key_location` = l'emplacement de votre export json contenant vos credentials (relatif par rapport au dossier part2.1)
> - `access_token_target_service_account` = le compte de service ayant les droits `Service Account Token Creator`
> - `docker_registry_address` = l'adresse de l'artifact registry (ex: `us-central1-docker.pkg.dev`)

Du fait d'un bug avec le provider k8s comme indiqué ici:
https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775

Il n'est pas possible dans le même apply d'avoir la création d'un cluster k8s et la création des manifests.

Pour éviter d'avoir à créer des sous dossiers, il faut faire ces 2 commandes:

- `terraform apply`

- `terraform apply -var="create_k8s=true"`

Amélioration effectué:

- [x] Pas besoin de modifier le yaml du tout (même les images)
- [x] Nous réutilisons bien les images de la partie 1
- [x] Les apply vont rebuild les images si le code du service à changé

## Pour la partie 2.2 (k8s sur gcp avec redis en offloaded)

> Ce mettre dans le dossier part2.2

> Faire `terraform init`

> Ouvrir le fichier part2.2/terraform.tfvars et indiqué les informations spécifique à votre projet:

> - `project_id`: l'id du projet sur gcp
> - `region` = la région du projet sur gcp
> - `zone` = la zone du projet sur gcp
> - `private_key_location` = l'emplacement de votre export json contenant vos credentials (relatif par rapport au dossier part2.1)
> - `access_token_target_service_account` = le compte de service ayant les droits `Service Account Token Creator`
> - `docker_registry_address` = l'adresse de l'artifact registry (ex: `us-central1-docker.pkg.dev`)

Du fait d'un bug avec le provider k8s comme indiqué ici:
https://github.com/hashicorp/terraform-provider-kubernetes/issues/1775

Il n'est pas possible dans le même apply d'avoir la création d'un cluster k8s et la création des manifests.

Pour éviter d'avoir à créer des sous dossiers, il faut faire ces 2 commandes:

- `terraform apply`

- `terraform apply -var="create_k8s=true"`

Nous avons eu beaucoup de mal pour communiquer l'ip de la vm redis aux pods. Nous avons essayé avec la ressource kubernetes_env mais ça n'a pas fonctionné.

Nous pensons qu'il y a surement possibilité de faire quelque chose avec les services mais nous n'avons pas eu le temps de trouver.

Nous avons donc choisi d'utiliser un secret kubernetes. (Pourriez-vous nous transmettre la bonne manière de faire merci.)
