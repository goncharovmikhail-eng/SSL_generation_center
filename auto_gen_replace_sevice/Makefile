CERTBOT_DIR := /root/SSL_generation_center/cerbot_docker
DOMAIN := express.crafttech.ru

ARCHIVE := $(CERTBOT_DIR)/letsencrypt/archive/$(DOMAIN)
DEST := /opt/express/nginx/certs

.PHONY: generate replace all

generate:
	@echo "=== Генерация сертификата ==="
	bash $(CERTBOT_DIR)/start.sh

replace:
	@echo "=== Замена сертификатов ==="

	@CERT=$$(ls -1 $(ARCHIVE)/fullchain*.pem | sort -V | tail -n 1); \
	KEY=$$(ls -1 $(ARCHIVE)/privkey*.pem | sort -V | tail -n 1); \
	echo "Сертификат: $$CERT"; \
	echo "Ключ: $$KEY"; \
	cp "$$CERT" "$(DEST)/express.crt"; \
	cp "$$KEY" "$(DEST)/express.key"

	@echo "Сертификаты скопированы."

	@echo "=== Перезапуск nginx ==="
	cd /opt/express && docker compose restart

all: generate replace
	@echo "=== SSL обновление завершено ==="
ssl_manager_install:
	@echo "=== Установка systemd unit-файлов ==="
	cp ssl_manager.service /etc/systemd/system/ssl_manager.service
	cp ssl_manager.timer /etc/systemd/system/ssl_manager.timer
	@echo "=== Перезагрузка systemd ==="
	systemctl daemon-reload
	@echo "=== Готово ==="
