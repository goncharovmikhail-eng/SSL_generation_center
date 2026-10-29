#!/bin/bash
set -euo pipefail

LASTNAME=""
OUTPUT_PATH="certs"
DOCKER_IMAGE="ca_stage"
DOMAINS=()
IP_ARGS=()
WILDCARD_ARGS=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name|--path|--ip)
      if [ "$#" -lt 2 ] || [[ "$2" == --* ]] || [ -z "$2" ]; then
        echo "Ошибка: для $1 требуется значение." >&2
        exit 1
      fi

      case "$1" in
        --name) DOMAINS+=("$2") ;;
        --path) OUTPUT_PATH="$2" ;;
        --ip) IP_ARGS+=(--ip "$2") ;;
      esac
      shift 2
      ;;
    --no-wildcard)
      WILDCARD_ARGS=(--no-wildcard)
      shift
      ;;
    --help)
      echo "Usage: $0 [Фамилия] [--name domain ...] [--path dir] [--ip ip ...] [--no-wildcard]"
      exit 0
      ;;
    -*)
      echo "Ошибка: неизвестный аргумент $1" >&2
      exit 1
      ;;
    *)
      if [ -n "$LASTNAME" ]; then
        echo "Ошибка: лишний аргумент $1" >&2
        exit 1
      fi
      LASTNAME="$1"
      shift
      ;;
  esac
done

if [ "${#DOMAINS[@]}" -eq 0 ]; then
  if [ -z "$LASTNAME" ]; then
    echo "Ошибка: укажи фамилию или хотя бы один --name." >&2
    exit 1
  fi
  DOMAINS=("${LASTNAME}.stage")
fi

mkdir -p "$OUTPUT_PATH"
OUTPUT_PATH="$(realpath "$OUTPUT_PATH")"

if ! docker image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
  docker build -t "$DOCKER_IMAGE" .
fi

NAME_ARGS=()
for domain in "${DOMAINS[@]}"; do
  NAME_ARGS+=(--name "$domain")
done

docker run --rm \
  -v "$OUTPUT_PATH:/certs" \
  -v "$OUTPUT_PATH:/root/.local/share/mkcert" \
  "$DOCKER_IMAGE" \
  "${NAME_ARGS[@]}" \
  "${IP_ARGS[@]}" \
  "${WILDCARD_ARGS[@]}"
