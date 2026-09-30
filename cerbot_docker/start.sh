#!/bin/bash

set -e

#read -p "Введите доменное имя: " name_domain
name_domain=express.crafttech.ru


if [[ -z "$name_domain" ]]; then
    echo "Домен не может быть пустым."
    exit 1
fi

#read -p "Введите email для Let's Encrypt: " email
email=m.goncharov@crafttech.ru

if [[ -z "$email" ]]; then
    echo "Email не может быть пустым."
    exit 1
fi

echo "Получаем сертификат..."

if ! docker compose run --rm --service-ports certbot certonly \
    --standalone \
    --preferred-challenges http \
    -d "$name_domain" \
    --email "$email" \
    --agree-tos \
    --non-interactive; then

    echo "Certbot завершился с ошибкой."
    exit 1
fi

docker compose down

CERT_PATH="./letsencrypt/live/$name_domain"

echo "Сертификат успешно получен!"
echo "Расположение: $CERT_PATH"

# Меняем владельца сертификатов на текущего пользователя
echo "Меняем владельца сертификатов на пользователя $USER..."
sudo chown -R $USER:$USER letsencrypt

echo "Готово"

