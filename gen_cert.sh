#!/bin/bash

# Умолчания
LASTNAME=""
DOMAIN=""
OUTPUT_PATH="certs/"
IP_ARGS=""
DOCKER_IMAGE="ca_stage"

while [ $# -gt 0 ]; do
  case "$1" in
    --name)
      DOMAIN="$2"
      shift 2
      ;;
    --path)
      OUTPUT_PATH="$2"
      shift 2
      ;;
    --ip)
      IP_ARGS="$IP_ARGS --ip $2"
      shift 2
      ;;
    --help)
      echo "Usage: ./gen_cert.sh [Фамилия] [--name domain.name] [--path output_dir] [--ip ip]"
      exit 0
      ;;
    *)
      if [ -z "$LASTNAME" ]; then
        LASTNAME="$1"
        shift
      else
        echo "❌ Unknown argument: $1"
        exit 1
      fi
      ;;
  esac
done

if [ -z "$DOMAIN" ]; then
  if [ -z "$LASTNAME" ]; then
    echo "❌ Error: You must specify either --name or a LASTNAME as first argument."
    exit 1
  fi
  DOMAIN="${LASTNAME}.stage"
fi

OUTPUT_PATH="$(realpath "$OUTPUT_PATH")"


if ! docker image inspect "$DOCKER_IMAGE" > /dev/null 2>&1; then
  echo "🔧 Docker image '$DOCKER_IMAGE' not found. Building..."
  docker build -t "$DOCKER_IMAGE" .
fi

mkdir -p "$OUTPUT_PATH"

echo "📣 Don't forget to add all required DNS and IPs (e.g. for '$DOMAIN')"
echo "🌍 Generating certificate for: $DOMAIN"
echo "📂 Output path: $OUTPUT_PATH"
echo "🌐 IP arguments: $IP_ARGS"

docker run --rm \
  -v "$OUTPUT_PATH:/certs" \
  -v "$OUTPUT_PATH:/root/.local/share/mkcert" \
  "$DOCKER_IMAGE" --name "$DOMAIN" $IP_ARGS
