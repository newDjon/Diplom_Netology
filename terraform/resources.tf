resource "yandex_compute_disk" "boot-disk-1" {
  name     = "boot-disk-1"
  type     = "network-hdd"
  zone     = var.zone
  size     = "20"
  image_id = "fd8h3lua68396l7s9lac"
}

resource "yandex_compute_disk" "boot-disk-2" {
  name     = "boot-disk-2"
  type     = "network-hdd"
  zone     = var.zone
  size     = "20"
  image_id = "fd8h3lua68396l7s9lac"
}

resource "yandex_compute_disk" "boot-disk-3" {
  name     = "boot-disk-3"
  type     = "network-hdd"
  zone     = var.zone
  size     = "20"
  image_id = "fd8h3lua68396l7s9lac"
}

resource "yandex_compute_disk" "boot-disk-4" {
  name     = "boot-disk-4"
  type     = "network-hdd"
  zone     = var.zone
  size     = "20"
  image_id = "fd8h3lua68396l7s9lac"
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = var.zone
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.2.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "subnet3"
  zone           = var.zone2
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.3.0/24"]
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "vm-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  name       = "vm-route-table"
  network_id     = yandex_vpc_network.network-1.id
  
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_iam_service_account" "netology" {
  name = "netology"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.netology.id}"
}


resource "yandex_vpc_security_group" "bastion" {
  name       = "bastion"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "accept ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

   egress {
    protocol       = "ANY"
    description    = "accept any out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix" {
  name       = "zabbix"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "accept zabbix-agent"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 10051
  }
  
  ingress {
    protocol       = "TCP"
    description    = "accept HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  } 

  egress {
    protocol       = "ANY"
    description    = "accept any out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "kibana"
  network_id = yandex_vpc_network.network-1.id

  ingress {
    protocol       = "TCP"
    description    = "accept HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  egress {
    protocol       = "ANY"
    description    = "accept any out"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "yandex_compute_instance" "bastion-server" {
  name = "bastion"
  zone = var.zone
  platform_id = "standard-v2"
  hostname = "bastion"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-1.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
	security_group_ids = [yandex_vpc_security_group.bastion.id]
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
  
  scheduling_policy {
    preemptible = true
  }

}

resource "yandex_compute_instance" "zabbix" {
  name = "zabbix"
  zone = var.zone
  platform_id = "standard-v2"
  hostname = "zabbix"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
	security_group_ids = [yandex_vpc_security_group.zabbix.id]
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
  
  scheduling_policy {
    preemptible = true
  }

}

resource "yandex_compute_instance" "kibana" {
  name = "kibana"
  zone = var.zone
  platform_id = "standard-v2"
  hostname = "kibana"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 5
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-3.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
	security_group_ids = [yandex_vpc_security_group.kibana.id]
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
  
  scheduling_policy {
    preemptible = true
  }

}

resource "yandex_compute_instance" "elastic" {
  name = "elastic"
  zone = var.zone
  platform_id = "standard-v2"
  hostname = "elastic"

  resources {
    cores  = 2
    memory = 4
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk-4.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    nat       = false
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
  
  scheduling_policy {
    preemptible = true
  }

}

resource "yandex_compute_instance_group" "vm-group" {
  name               = "vm-group"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.netology.id
    instance_template {
    platform_id        = "standard-v2"
    service_account_id = yandex_iam_service_account.netology.id
    name = "nginx{instance.index}"
    hostname = "nginx{instance.index}"
    resources {
      core_fraction = 5
      memory        = 1
      cores         = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd8h3lua68396l7s9lac"
        type     = "network-hdd"
        size     = 20
      }
    }

    network_interface {
      network_id         = yandex_vpc_network.network-1.id
      subnet_ids         = [yandex_vpc_subnet.subnet-2.id,yandex_vpc_subnet.subnet-3.id]
      nat                = false
    }

    metadata = {
    user-data = "${file("./meta.txt")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  
  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  application_load_balancer {
    target_group_name = "alb-tg"
  }
}

resource "yandex_alb_backend_group" "alb-bg" {
  name                     = "alb-bg"

  http_backend {
    name                   = "backend-1"
    port                   = 80
    target_group_ids       = [yandex_compute_instance_group.vm-group.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "alb-router" {
  name   = "alb-router"
}

resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb-router.id
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb-bg.id
        timeout = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb-1" {
  name               = "alb-1"
  network_id         = yandex_vpc_network.network-1.id
  
  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = yandex_vpc_subnet.subnet-2.id
    }

    location {
      zone_id   = var.zone2
      subnet_id = yandex_vpc_subnet.subnet-3.id
    }
   
  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb-router.id
      }
    }
  }
}

resource "yandex_compute_snapshot_schedule" "backup_disk" {
  name = "backup_disk"
 
    schedule_policy {
    expression = "0 1 ? * *"
  }
  
  snapshot_count = 7

  disk_ids = [
    "epdj0b1p0o2u6mgel497",
	"fhm4v9mu2eq76cdgnr58",
	"fhm99ae8svs4ps7mrg22",
	"fhm99m81ni948ni6p8b3",
	"fhmbqev9c369a5r92toi",
	"fhmskc93c3a4m3rtfgk1"
  ]
}  



