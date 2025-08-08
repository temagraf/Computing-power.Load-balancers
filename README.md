**Домашнее задание "Организация проекта при помощи облачных провайдеров"**

**Задание**

Организовать отказоустойчивую инфраструктуру в облаке Yandex Cloud с использованием Object Storage, группы виртуальных машин и сетевого балансировщика нагрузки.

**Выполнение задания**

**1. Создание Object Storage и размещение файла**

**1.1. Создание бакета**
```bash
yc storage bucket create --name temagraf-20250305
```
![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/1-1.png)

**1.2. Загрузка файла в бакет**   

```bash
aws --endpoint-url=https://storage.yandexcloud.net \
    s3 cp "/home/dextron/Загрузки/netologyRobots.png" \
    s3://temagraf-20250305/netologyRobots.png \
    --profile yc
```

![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/загрузка%20картинки%20в%20бакет.png)



**1.3.Настройка публичного доступа**

```bash
yc storage bucket update temagraf-20250305 --public-read
```

![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/1-3.png)


**2. Создание группы виртуальных машин**  
**2.1. Создание Instance Group**  

Конфигурация в файле instance-group.tf:  

```hcl
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
```

**2.2. Настройка веб-страницы через user-data** 

 ```hcl
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
                <img src="https://storage.yandexcloud.net/temagraf-20250305/netologyRobots.png">
              </body>
              </html>
              EOT
              EOF
    }
```
![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/BM%20.png)  

![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/целевые%20группы.png)  

![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/инфраструктура.png)

![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/Картинка%20и%20lamp.png)  


**3. Настройка балансировщика нагрузки**  
**3.1. Создание балансировщика**   

Конфигурация в файле load-balancer.tf:

```hcl
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
```

**3.2. Проверка отказоустойчивостиа**  
**Остановка одной ВМ:**

```bash
yc compute instance stop fhm2bv7ilt74m7kmjtv3
```

**Проверка списка ВМ после остановки:**

```bash
yc compute instance list
```

**Проверка работы балансировщика:**

```bash
yc load-balancer network-load-balancer list  
```

![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/3-2%20проверка.png)


**Результаты**  
**Созданная инфраструктура:**  
  
- Бакет Object Storage: temagraf-20250305  
- Группа из 3 ВМ с LAMP  
- Сетевой балансировщик нагрузки  
- IP балансировщика: 84.252.135.0  

![image](https://github.com/temagraf/Computing-power.Load-balancers/blob/main/балансировщик%20842521350.png)  

**Проверка работоспособности:**  
  
- Картинка доступна из интернета  
- Веб-сервер отвечает на запросы  
- Балансировщик распределяет нагрузку  
- Система сохраняет работоспособность при отказе одной ВМ   

Использованные файлы конфигурации

- provider.tf - настройки провайдера  
- network.tf - конфигурация сети  
- instance-group.tf - настройки группы ВМ  
- load-balancer.tf - конфигурация балансировщика
