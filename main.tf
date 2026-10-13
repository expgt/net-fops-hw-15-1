terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
    }
  }
  required_version = "~>1.16.0" /*Многострочный комментарий.
 Требуемая версия terraform */
}
provider "docker" {
  
  host = "ssh://ubuntu@VM-IP:22"
  ssh_opts = [
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null"
  ]
}

#однострочный комментарий

resource "random_password" "mysql_root_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}

resource "random_password" "mysql_password" {
  length      = 16
  special     = false
  min_upper   = 1
  min_lower   = 1
  min_numeric = 1
}


resource "docker_image" "mysql_image" {
  name         = "mysql:8"
  keep_locally = true
}

resource "docker_container" "mysql_container" {
  name  = "mysql"
  image = docker_image.mysql_image.image_id

  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }

  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root_password.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_password.result}",
    "MYSQL_ROOT_HOST=%"
  ]
}

output "mysql_root_password" {
  value     = random_password.mysql_root_password.result
  sensitive = true
}

output "mysql_password" {
  value     = random_password.mysql_password.result
  sensitive = true
}