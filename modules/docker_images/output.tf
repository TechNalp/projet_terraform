output "images" {
  value = {
    result = docker_image.result
    worker = docker_image.worker
    vote = docker_image.vote
    seed = docker_image.seed
    postgresql = try(docker_image.postgresql[0], null)
    redis = try(docker_image.redis[0], null)
    nginx = try(docker_image.nginx[0], null)
  }
}