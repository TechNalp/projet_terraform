locals {
  full_remote_regisry_address = var.push_on_remote_registry ? "${var.docker_registry_address}/${var.project_id}/terraform/" : ""
  platform = var.push_on_remote_registry ? "linux/amd64" : null
}

resource "docker_image" "result" {
  name = "${local.full_remote_regisry_address}result"
  build {
    context = "../src/voting-services/result/"
    platform = local.platform
  }

  triggers = {
    rebuild = sha1(join("", [for f in fileset("../src/voting-services/result", "*"): filesha1("../src/voting-services/result/${f}")]))
  }
}

resource "docker_registry_image" "result" {
  count = var.push_on_remote_registry ? 1 : 0
  name          = docker_image.result.name
  keep_remotely = true
}

//WORKER

resource "docker_image" "worker" {
  name = "${local.full_remote_regisry_address}worker"
  build {
    context = "../src/voting-services/worker/"
    platform = local.platform
  }

  triggers = {
    rebuild = sha1(join("", [for f in fileset("../src/voting-services/worker", "*"): filesha1("../src/voting-services/worker/${f}")]))
  }
}

resource "docker_registry_image" "worker" {
  count = var.push_on_remote_registry ? 1 : 0
  name          = docker_image.worker.name
  keep_remotely = true
}

//VOTE

resource "docker_image" "vote" {
  name = "${local.full_remote_regisry_address}vote"
  build {
    context = "../src/voting-services/vote/"
    platform = local.platform
  }

  triggers = {
    rebuild = sha1(join("", [for f in fileset("../src/voting-services/vote", "*"): filesha1("../src/voting-services/vote/${f}")]))
  }
}

resource "docker_registry_image" "vote" {
  count = var.push_on_remote_registry ? 1 : 0
  name          = docker_image.vote.name
  keep_remotely = true
}

//SEED-DATA

resource "docker_image" "seed" {
  name = "${local.full_remote_regisry_address}seed"
  build {
    context = "../src/voting-services/seed-data/"
    platform = local.platform
  }

  triggers = {
    rebuild = sha1(join("", [for f in fileset("../src/voting-services/seed-data", "*"): filesha1("../src/voting-services/seed-data/${f}")]))
  }
}

resource "docker_registry_image" "seed" {
  count = var.push_on_remote_registry ? 1 : 0
  name          = docker_image.seed.name
  keep_remotely = true
}


resource "docker_image" "nginx" {
  count = var.push_on_remote_registry ? 0 : 1
  name = "nginx"
  build {
    context = "../src/voting-services/nginx/"
  }

  triggers = {
    rebuild = sha1(join("", [for f in fileset("../src/voting-services/nginx", "*"): filesha1("../src/voting-services/nginx/${f}")]))
  }
}


resource "docker_image" "postgresql" {
  count = var.push_on_remote_registry ? 0 : 1
  name = "docker.io/postgres:15-alpine"
}

resource "docker_image" "redis" {
  count = var.push_on_remote_registry ? 0 : 1
  name = "docker.io/redis:6-alpine"
}