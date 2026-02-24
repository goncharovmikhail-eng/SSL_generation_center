#!/bin/bash

set -e

read -p "Введите доменное имя: " name_domain

if [[ -z "$name_domain" ]]; then
    echo "Домен не может быть пустым."
    exit 1
fi

read -p "Введите email для Let's Encrypt: " email

if [[ -z "$email" ]]; then
    echo "Email не может быть пустым."
    exit 1
fi

echo "Запускаем nginx..."
docker-compose up -d nginx

echo "Проверяем доступность домена..."
sleep 15

if ! curl -s --head "http://$name_domain" | grep "200" > /dev/null; then
    echo "Домен не отвечает по HTTP. Проверь DNS и порт 80."
    docker-compose down
    exit 1
fi

echo "Получаем сертификат..."

# Если certbot падает — ловим ошибку и делаем docker compose down
if ! docker-compose run --rm certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    -d "$name_domain" \
    #-d "www.$name_domain" \
    -d "*.$name_domain" \
    --email "$email" \
    --agree-tos \
    --no-eff-email; then
    echo "Certbot завершился с ошибкой. Останавливаем nginx..."
    docker-compose down
    exit 1
fi

echo "Перезапускаем nginx..."
#docker compose restart nginx
docker-compose down

CERT_PATH="./letsencrypt/live/$name_domain"

echo "Сертификат успешно получен!"
echo "Расположение: $CERT_PATH"

# Меняем владельца сертификатов на текущего пользователя
echo "Меняем владельца сертификатов на пользователя $USER..."
sudo chown -R $USER:$USER letsencrypt

echo "Готово"

