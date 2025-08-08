resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "network-load-balancer-new"  

  listener {
    name = "listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-1.load_balancer[0].target_group_id
    
    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

output "load_balancer_public_ip" {
  value = yandex_lb_network_load_balancer.lb-1.listener.*.external_address_spec[0].*.address
}
