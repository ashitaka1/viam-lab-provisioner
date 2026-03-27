# Quick Start

## One-time setup per target machine (BIOS)

Connect a monitor and keyboard to one machine of each model. Enter BIOS setup
(usually Del or F2 on System76 Meerkats).

1. **Boot order**: Move "Network Boot" / "IPv4 PXE" above the disk
2. **Power restore**: Set "Restore on AC Power Loss" to **Power On**
3. Save and exit

These settings are identical across units of the same model — note the exact
keystrokes so the rest of the batch can be done without a monitor if desired.

After provisioning, the autoinstall sets boot order back to disk-first, so
machines won't accidentally PXE boot again.

## PXE server setup

Run these on the machine that will serve as the PXE server (any machine on
the same network as the targets).

```bash
# 1. Clone the repo
git clone <repo-url> && cd viam-lab-provisioner

# 2. Create a Python venv and install the Viam SDK
python3 -m venv .venv
.venv/bin/pip install viam-sdk

# 3. Download Ubuntu ISO and extract kernel + initrd
./scripts/setup-pxe-server.sh

# 4. Add your secrets to config/
#    Copy from the .example files and fill in:
cp config/viam-credentials.env.example config/viam-credentials.env
cp config/tailscale.key.example config/tailscale.key
#    And place your SSH public key:
cp ~/.ssh/id_ed25519.pub config/ssh_host_key.pub

# 5. Generate the autoinstall config
./scripts/build-config.sh

# 6. Configure DHCP
#    Your network's DHCP server needs to hand out PXE boot options pointing
#    at this machine. The exact method depends on your router/DHCP server:
#
#    Option 66 (next-server): <this machine's IP>
#    Option 67 (filename):    netboot.xyz.efi
#
#    Alternatively, netboot-xyz can run as a ProxyDHCP alongside an existing
#    DHCP server — it responds only to PXE requests without interfering with
#    normal DHCP.

# 7. Start the PXE server stack
docker compose up -d
```

## Provisioning a batch

```bash
# 1. Create machines in Viam and stage credentials
./scripts/provision-batch.sh \
    --count 6 \
    --prefix lab-meerkat \
    --org-id <your-org-id> \
    --location-id <your-location-id>

# 2. Start the PXE watcher (in a separate terminal)
sudo python3 pxe-watcher/watcher.py -i <network-interface>

# 3. Power on machines one at a time
#    The watcher prints name assignments as each machine PXE boots:
#      [14:32:01] New PXE client: MAC aa:bb:cc:dd:ee:ff → assigned lab-meerkat-1
#      [14:32:18] New PXE client: MAC 11:22:33:44:55:66 → assigned lab-meerkat-2

# 4. Wait ~15 minutes for installs to complete
#    Machines appear in app.viam.com and on your Tailscale network automatically.
```

## After provisioning

- **SSH**: `ssh viam@<hostname>` (password: `checkmate`, or use your SSH key)
- **Viam**: machines appear at app.viam.com under the names you provisioned
- **Tailscale**: machines join your tailnet with their assigned hostnames
- **Re-provisioning**: use F10 one-time boot menu to PXE boot again (boot order is disk-first after install)
