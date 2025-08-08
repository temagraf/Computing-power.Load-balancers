resource "yandex_compute_instance_group" "ig-1" {
  name               = "fixed-ig-with-balancer-new"
  folder_id          = "b1gam4o6rj97es4peaq4"
  service_account_id = "ajeg971iui9o2i1ia9ai"
  
  instance_template {
    platform_id = "standard-v1"
    
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
      }
    }

    network_interface {
      network_id = yandex_vpc_network.network.id
      subnet_ids = [yandex_vpc_subnet.subnet.id]
      nat       = true
    }

    metadata = {
      user-data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              cat <<'EOT' > /var/www/html/index.html
              <html>
              <head>
                <style>
                  body { 
                    text-align: center;
                    font-family: Arial, sans-serif;
                  }
                  img { 
                    max-width: 800px;
                    height: auto;
                  }
                </style>
              </head>
              <body>
                <h1>Hello from LAMP server</h1>
                <img src="https://storage.yandexcloud.net/byzgaev-20250305/netologyRobots.png">
              </body>
              </html>
              EOT
              EOF
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  health_check {
    http_options {
      port = 80
      path = "/"
    }
  }

  load_balancer {
    target_group_name = "target-group"
  }
}
