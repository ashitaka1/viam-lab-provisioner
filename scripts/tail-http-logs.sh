#!/usr/bin/env bash
# Tails HTTP server logs, prints them, and creates PXE guard files
# when a machine's hostname is fetched (indicating successful install).

GUARD_DIR="${1:?Usage: $0 <guard-dir>}"
mkdir -p "$GUARD_DIR"

docker logs -f pxe-http 2>&1 | while IFS= read -r line; do
    # Skip nginx startup noise
    case "$line" in
        *worker*|*notice*|*entrypoint*|*envsubst*|*resolvers*|*tune-worker*|*"Configuration complete"*) continue ;;
    esac

    echo "$line"

    # When a machine fetches its hostname, the install succeeded.
    # Create a GRUB guard so it won't re-install on next PXE boot.
    MAC=$(echo "$line" | grep -oE 'GET /machines/[0-9a-f:]+/hostname.* 200' | sed 's|GET /machines/||;s|/hostname.*||')
    if [ -n "$MAC" ] && [ ! -f "$GUARD_DIR/$MAC.cfg" ]; then
        echo "exit" > "$GUARD_DIR/$MAC.cfg"
        echo "  [guard] PXE guard created for $MAC"
    fi
done
