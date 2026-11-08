## Деплой на удалённый сервер по SSH/SCP

Описание безопасной передачи файлов проекта на удаленных сервер 
с исспользованием пары ssh-ключей (публичный и приватный).


### 1. Генерация SSH-ключей

```bash
ssh-keygen -t ed25519 -C "deploy@infra-monitoring" -f ~/.ssh/id_ed25519_infra
```

### 2. Копирование публичного ключа на сервер

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_infra.pub user@server.example.com
```

#### Вход по ключу проверяется так

```bash
ssh -i ~/.ssh/id_ed25519_infra user@server.example.com
```

### 3. Передача архива проекта scp

#### Архивируем проект, исключая лишнее
```bash
tar -czf infra-monitoring.tar.gz \
    --exclude='.git' \
    --exclude='*.log' \
    .
```

#### Копируем архив на сервер
```bash
scp -i ~/.ssh/id_ed25519_infra infra-monitoring.tar.gz \
    user@server.example.com:/opt/deploy/
```

#### На сервере распаковываем
```bash
ssh -i ~/.ssh/id_ed25519_infra user@server.example.com \
    "cd /opt/deploy && tar -xzf infra-monitoring.tar.gz"
```

### 4. Пример полного деплоя

```bash
# собираем проект в архив и отправляем на сервер с последующей распаковкой
tar -czf - --exclude='.git' --exclude='*.log' --exclude='access.log' . \
  | ssh -i ~/.ssh/id_ed25519_infra user@server.example.com \
      "mkdir -p /opt/infra-monitoring && tar -xzf - -C /opt/infra-monitoring"

# поднимаем контейнеры на сервере
ssh -i ~/.ssh/id_ed25519_infra user@server.example.com \
    "cd /opt/infra-monitoring && docker compose up -d"

# проверка работы сервиса
ssh -i ~/.ssh/id_ed25519_infra user@server.example.com \
    "curl -s http://localhost:80"
```