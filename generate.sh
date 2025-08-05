#!/bin/sh
set -e

DOMAIN=""
OUTPUT_DIR="${OUTPUT_DIR:-/certs}"
MKCERT_ROOT="/root/.local/share/mkcert"
IPS="127.0.0.1 localhost"

# Парсинг аргументов
while [ $# -gt 0 ]; do
  case "$1" in
    --name)
      DOMAIN="$2"
      shift 2
      ;;
    --ip)
      IPS="$IPS $2"
      shift 2
      ;;
    --help)
      echo "Usage: docker run ... --name domain.name [--ip ip-address]"
      exit 0
      ;;
    *)
      echo "❌ Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [ -z "$DOMAIN" ]; then
  echo "❌ Error: Domain not specified. Use --name."
  exit 1
fi

echo "🔧 Generating certificate for domain: $DOMAIN"
echo "📁 Output directory: $OUTPUT_DIR"
echo "🌐 IPs: $IPS"

mkcert -install

mkcert -cert-file "$OUTPUT_DIR/$DOMAIN.pem" \
       -key-file "$OUTPUT_DIR/$DOMAIN.key" \
       "$DOMAIN" "*.$DOMAIN" $IPS

echo "DEBUG: Listing cert files:"
ls -l "$OUTPUT_DIR"

echo "DEBUG: Contents of cert and key files:"
head -10 "$OUTPUT_DIR/$DOMAIN.pem"
head -10 "$OUTPUT_DIR/$DOMAIN.key"

cat "$OUTPUT_DIR/$DOMAIN.key" "$OUTPUT_DIR/$DOMAIN.pem" > "$OUTPUT_DIR/$DOMAIN-combined.pem"
mv "$OUTPUT_DIR/$DOMAIN-combined.pem" "$OUTPUT_DIR/$DOMAIN.pem"

cat "$OUTPUT_DIR/$DOMAIN.pem" "$MKCERT_ROOT/rootCA.pem" > "$OUTPUT_DIR/$DOMAIN.crt"
cp "$MKCERT_ROOT/rootCA.pem" "$OUTPUT_DIR/rootCA.crt"

chmod 777 "$OUTPUT_DIR/$DOMAIN.pem" \
          "$OUTPUT_DIR/$DOMAIN.key" \
          "$OUTPUT_DIR/$DOMAIN.crt" \
          "$OUTPUT_DIR/rootCA.crt"
