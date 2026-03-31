.PHONY: watch dhcp up down build-config setup status

watch:
	sudo .venv/bin/python3 pxe-watcher/watcher.py

dhcp:
	sudo dnsmasq --conf-file=netboot/dnsmasq.conf --tftp-root=$(CURDIR)/netboot --log-facility=$(CURDIR)/dnsmasq.log --no-daemon 2>&1 | grep -v '^dnsmasq-dhcp'

up:
	docker compose up -d

down:
	docker compose down

build-config:
	./scripts/build-config.sh

setup:
	./scripts/setup-pxe-server.sh

status:
	@echo "=== Queue ==="
	@.venv/bin/python3 -c "import json; q=json.load(open('http-server/machines/queue.json')); \
	  [print(f\"  {'✓' if s.get('assigned') else '○'} {s['name']:<25} {s.get('mac', 'waiting...')}\") for s in q]"
	@echo ""
	@echo "=== Services ==="
	@docker compose ps --format 'table {{.Name}}\t{{.Status}}' 2>/dev/null || echo "  Docker not running"
	@pgrep -x dnsmasq >/dev/null 2>&1 && echo "  dnsmasq: running" || echo "  dnsmasq: stopped"
