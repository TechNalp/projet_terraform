module "docker_images" {
  source = "../modules/docker_images"
}

module "docker" {
  source = "../modules/docker"

  docker_images = module.docker_images.images

}