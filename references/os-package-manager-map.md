# OS / Package Manager Map

| Distro family | Package manager | Update command | Service manager | Default firewall | Log locations |
|---|---|---|---|---|---|
| Debian / Ubuntu | apt | `apt update && apt upgrade` | systemd (`systemctl`) | ufw (often present), else raw iptables/nftables | `/var/log/syslog`, `/var/log/auth.log` |
| RHEL / CentOS / Rocky / Alma | dnf (yum on older releases) | `dnf update` | systemd | firewalld | `/var/log/messages`, `/var/log/secure` |
| Fedora | dnf | `dnf update` | systemd | firewalld | `/var/log/messages`, `/var/log/secure` |
| SUSE / openSUSE | zypper | `zypper update` | systemd | firewalld / SuSEfirewall2 | `/var/log/messages` |
| Alpine | apk | `apk update && apk upgrade` | OpenRC | none by default | `/var/log/messages` (if `syslog` installed; Alpine is minimal by design) |
| Arch | pacman | `pacman -Syu` | systemd | none by default | `journalctl` (systemd-only, no flat log files by default) |

## Common package-name variants across distros

Don't assume a package name is identical everywhere — confirm before running an install command:

- **nginx**: `nginx` on all of the above.
- **PHP-FPM**: `php-fpm` (RHEL family) vs. `php8.x-fpm` (Debian/Ubuntu, version-specific) vs. `php8-fpm` (Alpine).
- **fail2ban**: `fail2ban` everywhere, but the default jail config path differs (`/etc/fail2ban/jail.local` convention is consistent; distro-provided defaults vary).
- **Docker**: prefer the distro's official Docker repo over the distro's own `docker`/`docker.io` package where the user wants a current version — the bundled package is often older.
- **Node.js**: rarely current in distro repos; prefer NodeSource or a version manager (nvm/fnm) over the distro package unless the user is fine with an older version.

When in doubt, search the package manager's index (`apt search`, `dnf search`, `apk search`) rather than guessing the exact name.
