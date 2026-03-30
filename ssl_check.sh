#!/bin/bash

CERT=$1
KEY=$2

# сравниваем публичные ключи
openssl x509 -in "$CERT" -noout -pubkey > pub_from_crt.pem
openssl pkey -in "$KEY" -pubout > pub_from_key.pem

echo "👉 Сравнение публичных ключей из сертификата и ключа:"
if diff pub_from_crt.pem pub_from_key.pem >/dev/null ; then
    echo "✅ Совпадают"
else
    echo "❌ НЕ совпадают"
fi

echo "======="

# Проверяем тип ключа
KEY_TYPE=$(openssl pkey -in "$KEY" -text -noout 2>/dev/null | head -1)

if echo "$KEY_TYPE" | grep -qi "RSA"; then
    echo "👉 Обнаружен RSA ключ"
    openssl x509 -noout -modulus -in "$CERT" | openssl md5
    openssl rsa -noout -modulus -in "$KEY" | openssl md5
elif echo "$KEY_TYPE" | grep -qi "EC"; then
    echo "👉 Обнаружен EC ключ"
    # Для EC modulus не применим, сравнение только через pubkey
else
    echo "⚠️ Не удалось определить тип ключа"
fi

echo "======="

# показываем домены в сертификате
echo "👉 Сертификат выдан на:"
openssl x509 -in "$CERT" -noout -text | grep -A1 "Subject Alternative Name"

# показываем кем выдан
echo "👉 Выдан:"
openssl x509 -in "$CERT" -noout -issuer

