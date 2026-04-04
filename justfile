# PXE/SD provisioning commands

# Start PXE watcher (assigns names to MACs as machines boot)
watch:
    sudo .venv/bin/python3 pxe-watcher/watcher.py

# Start dnsmasq proxy DHCP + TFTP server
dhcp:
    sudo dnsmasq --conf-file=netboot/dnsmasq.conf --tftp-root={{justfile_directory()}}/netboot --log-facility={{justfile_directory()}}/dnsmasq.log --no-daemon 2>&1 | grep -v '^dnsmasq-dhcp'

# Start HTTP server (Docker)
up:
    docker compose up -d

# Stop HTTP server
down:
    docker compose down

# Generate autoinstall user-data from template + secrets
build-config:
    ./scripts/build-config.sh

# Extract GRUB, kernel, initrd from Ubuntu ISO (one-time setup)
setup:
    ./scripts/setup-pxe-server.sh

# Create machines in Viam and stage credentials
provision config:
    ./scripts/provision-batch.sh --config {{config}}

# Flash a Pi SD card
flash device name:
    ./scripts/flash-pi-sd.sh {{device}} {{name}}

# Reset queue (mark all slots unassigned, re-use same batch)
reset:
    #!/usr/bin/env bash
    echo "Resetting queue (marking all slots as unassigned)..."
    .venv/bin/python3 -c "import json; \
      q=json.load(open('http-server/machines/queue.json')); \
      [s.update({'assigned': False, 'mac': None}) for s in q]; \
      json.dump(q, open('http-server/machines/queue.json', 'w'), indent=2)"
    echo "Cleaning MAC-keyed directories..."
    rm -rf http-server/machines/[0-9a-f][0-9a-f]:*
    echo "Done. Queue ready for re-use."

# Wipe all provisioning state (between batches)
clean:
    #!/usr/bin/env bash
    echo "Removing all provisioning state from http-server/machines/..."
    rm -rf http-server/machines/[0-9a-f][0-9a-f]:*
    rm -rf http-server/machines/slot-*
    rm -f http-server/machines/queue.json
    echo "Clean. Run provision-batch.sh to start a new batch."

# Show queue state and service status
status:
    #!/usr/bin/env bash
    echo "=== Queue ==="
    if [ -f http-server/machines/queue.json ]; then
      .venv/bin/python3 -c "import json; q=json.load(open('http-server/machines/queue.json')); \
        [print(f\"  {'✓' if s.get('assigned') else '○'} {s['name']:<25} {s.get('mac', 'waiting...')}\") for s in q]"
    else
      echo "  No queue. Run provision-batch.sh first."
    fi
    echo ""
    echo "=== Services ==="
    docker compose ps --format 'table {{{{.Name}}}}\t{{{{.Status}}}}' 2>/dev/null || echo "  Docker not running"
    pgrep -x dnsmasq >/dev/null 2>&1 && echo "  dnsmasq: running" || echo "  dnsmasq: stopped"
