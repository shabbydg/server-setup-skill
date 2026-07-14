# Environment Detection

Run once per host, in Step 0, before any of the three workflows. Prefer running `scripts/recon.sh` in a single SSH round trip over issuing these one at a time.

## SSH access pattern

- Check `~/.ssh/config` locally for a `Host` entry matching the target — note `ProxyJump`/`ProxyCommand` (bastion/jump host), a non-default `Port`, and which `IdentityFile` applies.
- If nothing is configured locally, ask the user for the connection string rather than guessing.
- A bastion/jump host is itself possibly shared infrastructure — treat changes that touch it with extra caution (see `edge-cases.md`).

## Provider detection

Query the cloud-metadata endpoint with a short timeout (2–3s) so a host with no metadata service (generic VPS, air-gapped, on-prem) doesn't stall recon:

- **AWS (EC2 and Lightsail, which is EC2-backed):** `curl -s -m 3 http://169.254.169.254/latest/meta-data/` — requires an IMDSv2 token on newer instances (`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`, then pass it as `X-aws-ec2-metadata-token` on subsequent requests). Lightsail vs. plain EC2 is not reliably distinguishable from inside the box — cross-check against what the user said rather than asserting confidently.
  - **Never fetch `.../iam/security-credentials/<role-name>`** — this returns live, temporary IAM credentials. Treat it as off-limits, not just uninteresting.
- **DigitalOcean:** `curl -s -m 3 http://169.254.169.254/metadata/v1/`.
- **GCP:** `curl -s -m 3 -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/`.
- **Azure:** `curl -s -m 3 -H "Metadata:true" "http://169.254.169.254/metadata/instance?api-version=2021-02-01"`.
- **No response / timeout:** generic VPS or bare metal (Hetzner, Vultr, Linode, OVH, on-prem). Fall back to `dmidecode -s system-manufacturer` or `/sys/class/dmi/id/*`, or just ask the user.

## OS / distro detection

1. `cat /etc/os-release` (fields `ID`, `VERSION_ID`, `ID_LIKE`) — primary source.
2. Fallback: `lsb_release -a`.
3. Fallback: `uname -a`.

## Package / service / firewall manager mapping

| Distro family | Package manager | Service manager | Default firewall tool |
|---|---|---|---|
| Debian / Ubuntu | apt | systemd | ufw (often), raw iptables/nftables |
| RHEL / CentOS / Rocky / Alma / Fedora | dnf (yum on older) | systemd | firewalld |
| SUSE | zypper | systemd | firewalld / SuSEfirewall2 |
| Alpine | apk | OpenRC | none by default — iptables if present |
| Arch | pacman | systemd | none by default |

Minimal/hardened images may ship with no firewall tool installed at all — don't assume one exists.

## Container / virtualization detection

- `systemd-detect-virt` (reports `none`, `kvm`, `docker`, `lxc`, etc.)
- `cat /proc/1/cgroup` — cgroup paths containing `docker`/`kubepods` indicate a container, not a full VM.
- This changes what "hardening the host" even means — see `edge-cases.md` for the Docker/Kubernetes case.

## Read-only / immutable root filesystem

- Check `mount | grep ' / '` for a `ro` flag — affects install strategy on hardened/immutable AMIs (e.g. Bottlerocket-style images).

## Existing config-management detection

- Look for `/etc/ansible`, Chef/Puppet agent installs, `/var/lib/cloud` (cloud-init), or Terraform-style tags in the provider metadata.
- If present, warn the user that manual changes may be overwritten by or fight the existing IaC, and confirm before proceeding anyway.

## Network stack

- `ip -6 addr` and the default route table to detect IPv6-only or dual-stack hosts — firewall and service-binding checks later must cover both stacks, not just IPv4.

## Egress reachability

- Check reachability to the OS's package mirror early (e.g. `curl -sI -m 5 <distro mirror>`). A restricted-egress/air-gapped host should fail fast here, not mid-install in Workflow A.
