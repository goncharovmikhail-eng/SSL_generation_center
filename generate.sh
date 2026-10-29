#!/bin/bash
set -euo pipefail
umask 077

OUTPUT_DIR="${OUTPUT_DIR:-/certs}"
export CAROOT="/root/.local/share/mkcert"

DOMAINS=()
IPS=("127.0.0.1" "localhost")
ADD_WILDCARD=true

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name|--ip)
      if [ "$#" -lt 2 ] || [[ "$2" == --* ]] || [ -z "$2" ]; then
        echo "Ошибка: для $1 требуется значение." >&2
        exit 1
      fi

      case "$1" in
        --name) DOMAINS+=("$2") ;;
        --ip) IPS+=("$2") ;;
      esac
      shift 2
      ;;
    --no-wildcard)
      ADD_WILDCARD=false
      shift
      ;;
    --help)
      echo "Usage: --name domain [--name domain ...] [--ip ip ...] [--no-wildcard]"
      exit 0
      ;;
    *)
      echo "Ошибка: неизвестный аргумент $1" >&2
      exit 1
      ;;
  esac
done

if [ "${#DOMAINS[@]}" -eq 0 ]; then
  echo "Ошибка: укажи хотя бы один --name." >&2
  exit 1
fi

CERT_NAMES=()

for domain in "${DOMAINS[@]}"; do
  if [[ "$domain" == */* ]]; then
    echo "Ошибка: --name должен содержать DNS-имя без URL и пути." >&2
    exit 1
  fi

  CERT_NAMES+=("$domain")

  if [ "$ADD_WILDCARD" = true ] && [[ "$domain" != \*.* ]]; then
    CERT_NAMES+=("*.$domain")
  fi
done

# Для явно переданного wildcard используем безопасное имя файла.
FILE_NAME="${DOMAINS[0]//\*/wildcard}"

mkdir -p "$OUTPUT_DIR" "$CAROOT"

echo "Имена в сертификате: ${CERT_NAMES[*]} ${IPS[*]}"
echo "Каталог результата: $OUTPUT_DIR"

mkcert -install

mkcert \
  -cert-file "$OUTPUT_DIR/$FILE_NAME.pem" \
  -key-file "$OUTPUT_DIR/$FILE_NAME.key" \
  "${CERT_NAMES[@]}" \
  "${IPS[@]}"

# Сертификат вместе с корневым CA, без приватного ключа.
cat "$OUTPUT_DIR/$FILE_NAME.pem" "$CAROOT/rootCA.pem" \
  > "$OUTPUT_DIR/$FILE_NAME.crt"

if [ ! -e "$OUTPUT_DIR/rootCA.crt" ]; then
  cp "$CAROOT/rootCA.pem" "$OUTPUT_DIR/rootCA.crt"
fi

chmod 777 \
  "$OUTPUT_DIR/$FILE_NAME.pem" \
  "$OUTPUT_DIR/$FILE_NAME.key" \
  "$OUTPUT_DIR/$FILE_NAME.crt" \
  "$OUTPUT_DIR/rootCA.crt"

echo "Готово:"
printf '  %s\n' \
  "$OUTPUT_DIR/$FILE_NAME.pem" \
  "$OUTPUT_DIR/$FILE_NAME.key" \
  "$OUTPUT_DIR/$FILE_NAME.crt" \
  "$OUTPUT_DIR/rootCA.crt"
