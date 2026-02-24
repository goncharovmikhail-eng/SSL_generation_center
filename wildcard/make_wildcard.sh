#!/bin/bash

set -e

read -p "Введите доменное имя (без *): " name_domain
read -p "Введите email: " email

if [[ -z "$name_domain" || -z "$email" ]]; then
    echo "Домен и email обязательны"
    exit 1
fi

echo "Запускаем certbot для wildcard..."

docker run --rm -it \
  -v "$(pwd)/letsencrypt:/etc/letsencrypt" \
  certbot/certbot certonly \
  --manual \
  --preferred-challenges dns \
  -d "$name_domain" \
  -d "*.$name_domain" \
  --email "$email" \
  --agree-tos \
  --no-eff-email

sudo chown -R $USER:$USER letsencrypt
echo "Готово."
echo "Сертификаты находятся в:"
echo "./letsencrypt/live/$name_domain/"
