terraform {
 required_providers {
   yandex = {
     source = "yandex-cloud/yandex"
   }
 }
 required_version = ">= 0.13"
}

provider "yandex" {
  token     = "Яндекс OAuth token"
  cloud_id  = "id_облака"
  folder_id = "id_папки"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "some_node" {
  name = "some_name" #полезно давать простое уникальное значение, чтобы потом использовать его в yandex CLI
  platform_id = "standard-v3" #наиболее бюджетная конфигурация на базе Intel Ice Lake

  resources {
    cores  = 2 #количество ядер
    memory = 4 #объем памяти GB
  }

  boot_disk {
    initialize_params {
      type     = "network-hdd" #можно изменить на "network-ssd", будет быстрее, но дороже
      size     = 40 #размер загрузочного дика GB. 
      image_id = "fd82re2tpfl4chaupeuf" #установочный образ ОС. В данном примере CentOS 7
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id 
    nat       = true
  }
  
  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}
resource "yandex_vpc_network" "network-1" {
  name = "network1" #название сети. оставить как есть либо заменить на свой вариант во всем документе
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1" #название подсети. оставить как есть либо заменить на свой вариант во всем документе
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"] #пулл серых адресов для создаваемой подсети
}

output "internal_ip_address_some_node" {
  value = yandex_compute_instance.some_node.network_interface.0.ip_address
}
output "external_ip_address_some_node" {
  value = yandex_compute_instance.some_node.network_interface.0.nat_ip_address
}