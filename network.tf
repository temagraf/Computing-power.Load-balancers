resource "yandex_vpc_network" "network" {
  name = "network-byzgaev-new"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet-byzgaev-new"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
