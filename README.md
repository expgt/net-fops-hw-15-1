# Домашнее задание к занятию «Введение в Terraform» - Розаев А.Ю.

### Цели задания

1. Установить и настроить Terrafrom.
2. Научиться использовать готовый код.

------

### Чек-лист готовности к домашнему заданию

![0](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_0.png)

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. Репозиторий с ссылкой на зеркало для установки и настройки Terraform: [ссылка](https://github.com/netology-code/devops-materials).
2. Установка docker: [ссылка](https://docs.docker.com/engine/install/ubuntu/). 
------
### Внимание!! Обязательно предоставляем на проверку получившийся код в виде ссылки на ваш github-репозиторий!
------

### Задание 1

1. Скачены все необходимые зависимости, используемые в проекте

2. Изучен файл .gitignore. Согласно этому файлу, допустимо сохранять личную и секретную информацию (логины,пароли,ключи,токены и т.д.) в файле personal.auto.tfvars

3. Выполнен код проекта. В state-файле найдено секретное содержимое созданного ресурса **random_password**, ключ и его значение:
   
```
result = m51Y8pbuERorSWNn
```

![1_3](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_1_3.png)
   
4. Раскомментирован блок кода, расположенный на строчках 29–42 файла **main.tf**.Выполнена команда ```terraform validate```.
При проверке кода и их поэтапного исправления обнаружены следующие ошибки:

```bash
│ Error: Missing name for resource
│ 
│   on main.tf line 23, in resource "docker_image":
│   23: resource "docker_image" {
│ 
│ All resource blocks must have 2 labels (type, name).
```
Данная ошибка означает, что в блоке resource начинающегося на строке 23 не указано имя ресурса.

```bash
│ Error: Invalid resource name
│ 
│   on main.tf line 28, in resource "docker_container" "1nginx":
│   28: resource "docker_container" "1nginx" {
│ 
│ A name must start with a letter or underscore and may contain only letters, digits, underscores, and dashes.
```
Данная ошибка означает, что в блоке resource начинающегося на строке 28 неправильно указано имя ресурса, т.к. оно начинает на цифру.

После исправления первых двух ошибок и попытки запуска, появляется еще одна.

```bash
│ Error: Reference to undeclared resource
│ 
│   on main.tf line 30, in resource "docker_container" "nginx":
│   30:   name  = "example_${random_password.random_string_FAKE.resulT}"
│ 
│ A managed resource "random_password" "random_string_FAKE" has not been declared in the root module.
```
Данная ошибка означает, что внутри ресурса "docker_container" "nginx" используется другой ресурс "random_password" "random_string_FAKE", который не был объявлен.
	
После исправления данного ресурса на random_password.random_string.resulT появляется ошибка:

```bash
│ Error: Unsupported attribute
│ 
│   on main.tf line 30, in resource "docker_container" "nginx":
│   30:   name  = "example_${random_password.random_string.resulT}"
│ 
│ This object has no argument, nested block, or exported attribute named "resulT". Did you mean "result"?
```
которая сообщает, что неверно указан аргумент "resulT"

5. После исправления данных ошибок код запустился.

Исправленный блок кода:

```bash
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"

  ports {
    internal = 80
    external = 9090
  }
}
```

![1_5](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_1_5.png)


6. Произведена замена имени docker-контейнера в блоке кода на ```hello_world```. Выполнена команда ```terraform apply -auto-approve```.
Ключ  ```-auto-approve``` запускает процесс развертывания или обновления инфраструктуры, минуя этап интерактивного подтверждения.
В данном случае был удален контейнер nginx (т.к. отсутствует в конфигурации) и создан hello_world, но проконтролировать это не было возможности из-за ключа -auto-approve.
Такой сценарий опасен при работе в production-окружении, когда можно непреднамеренно удалить рабочий контейнер.
При этом, данный ключ полезен в сценарях без участия человека, например, в автоматических пайплайнах.

![1_6](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_1_6.png)


7. Созданные ресурсы удалены с помощью **terraform**.
Содержимое файла **terraform.tfstate**:

![1_7](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_1_7.png)

8. Docker-образ **nginx:latest** не был удален, т.к. в блоке образа использована опция keep_locally, которая при значении true позволяет сохранить образ в локальном репозитории docker 

```bash
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}
```
Документация:
keep_locally (Boolean) If true, then the Docker image won't be deleted on destroy operation. If this is false, it will delete the image from the docker local storage on destroy operation. 
[Doc](https://library.tf/providers/kreuzwerker/docker/latest/docs/resources/image#:~:text=keep%5Flocally%20%28Boolean%29%20If%20true%2C%20then%20the%20Docker%20image%20won%27t%20be%20deleted%20on%20destroy%20operation%2E%20If%20this%20is%20false%2C%20it%20will%20delete%20the%20image%20from%20the%20docker%20local%20storage%20on%20destroy%20operation)


---

## Дополнительное задание (со звёздочкой*)

### Задание 2*

1. В облаке создана ВМ.

![2_1](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_2_1.png)

2. На ВМ установлен стек docker.

![2_2](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_2_2.png)

3. Документация docker provider по подключению terraform к remote docker context в облачной ВМ через ssh.

[Doc](https://library.tf/providers/kreuzwerker/docker/latest#remote-hosts)

4. Используя terraform и remote docker context, скачан и запущен на облачной ВМ контейнер ```mysql:8``` на порту ```127.0.0.1:3306```, переданы ENV-переменные. Сгенерированы разные пароли через random_password и переданы в контейнер, использована интерполяция из примера с nginx.(```name  = "example_${random_password.random_string.result}"```).

![2_4](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_2_4.png)

6. На облачной ВМ, произведено подключение к контейнеру и проверено наличие секретных env-переменных с помощью команды ```env```. Финальный код добавлен в репозиторий.

![2_6](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_2_6.png)

---

### Задание 3*
1. Установлен [opentofu](https://opentofu.org/)(fork terraform с лицензией Mozilla Public License, version 2.0)

![3_1](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_3_1.png)

2. Выполнен код из Задания 2 с помощью ```tofu apply```.

![3_2](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_3_2.png)

![3_3](https://github.com/expgt/net-fops-hw-15-1/blob/main/15_1_3_3.png)

---

