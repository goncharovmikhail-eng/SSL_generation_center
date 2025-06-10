FROM debian:latest

RUN apt-get update && apt-get install -y \
    mkcert \
    libnss3-tools \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /certs
VOLUME /certs

COPY generate.sh /generate.sh
RUN chmod +x /generate.sh

ENTRYPOINT ["/generate.sh"]
