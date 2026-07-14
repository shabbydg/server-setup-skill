#!/usr/bin/env bash
# Read-only recon battery for remote-server-ops (Step 0 detection + server-recon subagent data source).
#
# Usage: ssh <host> 'bash -s' < scripts/recon.sh
#        ssh <host> 'bash -s -- --deep' < scripts/recon.sh   # adds incident-response evidence collection
#
# Strictly read-only: no writes, no installs, no service/process changes. Safe to run without confirmation.
set -uo pipefail

DEEP=0
[ "${1:-}" = "--deep" ] && DEEP=1

section() { printf '\n===== %s =====\n' "$1"; }
run() { echo "\$ $*"; eval "$@" 2>&1 || echo "(command failed or unavailable: $*)"; }

section "OS / distro"
run "cat /etc/os-release 2>/dev/null || lsb_release -a 2>/dev/null || uname -a"

section "Provider metadata (best-effort, short timeout, credential paths excluded)"
run "curl -s -m 2 -H 'Metadata-Flavor: Google' http://169.254.169.254/computeMetadata/v1/ 2>/dev/null | head -20"
run "curl -s -m 2 http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null"
run "curl -s -m 2 http://169.254.169.254/metadata/v1/id 2>/dev/null"

section "Virtualization / container detection"
run "systemd-detect-virt 2>/dev/null"
run "cat /proc/1/cgroup 2>/dev/null | head -5"

section "Package manager present"
run "command -v apt dnf yum zypper apk pacman 2>/dev/null"

section "Service manager"
run "command -v systemctl 2>/dev/null && systemctl --version | head -1"

section "Firewall tool present"
run "command -v ufw firewalld iptables nft 2>/dev/null"

section "Network — addresses and routes"
run "ip -4 addr show"
run "ip -6 addr show"
run "ip route show"

section "Listening ports / connections"
run "ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null"

section "Running processes (top by CPU)"
run "ps auxww --sort=-%cpu 2>/dev/null | head -30"

section "Installed / running services overview"
run "systemctl list-units --type=service --state=running --no-pager 2>/dev/null | head -40"

section "Users and sudoers"
run "cat /etc/passwd | awk -F: '\$3 >= 1000 {print}'"
run "grep -R '' /etc/sudoers.d/ 2>/dev/null"
run "getent group sudo wheel 2>/dev/null"

section "Cron / timers"
run "for u in \$(cut -f1 -d: /etc/passwd); do crontab -l -u \"\$u\" 2>/dev/null; done"
run "ls -la /etc/cron.d/ /etc/cron.daily/ 2>/dev/null"
run "systemctl list-timers --no-pager 2>/dev/null"

section "authorized_keys across all users"
run "for h in /root /home/*; do [ -f \"\$h/.ssh/authorized_keys\" ] && echo \"-- \$h --\" && cat \"\$h/.ssh/authorized_keys\"; done"

section "sshd_config values"
run "grep -E '^(PermitRootLogin|PasswordAuthentication|Port|AllowUsers|AllowGroups|MaxAuthTries)' /etc/ssh/sshd_config 2>/dev/null"

section "Firewall rules (display only)"
run "ufw status verbose 2>/dev/null"
run "firewall-cmd --list-all 2>/dev/null"
run "iptables -L -n -v 2>/dev/null | head -40"

section "Recent auth failures"
run "grep -i 'failed\|invalid' /var/log/auth.log 2>/dev/null | tail -20"
run "grep -i 'failed\|invalid' /var/log/secure 2>/dev/null | tail -20"

section "Disk usage"
run "df -h"

section "Config-management artifacts"
run "ls -la /etc/ansible /var/lib/cloud 2>/dev/null"
run "command -v chef-client puppet 2>/dev/null"

section "Egress reachability (package mirror)"
run "curl -sI -m 5 http://deb.debian.org 2>/dev/null | head -1"
run "curl -sI -m 5 http://mirrorlist.centos.org 2>/dev/null | head -1"

if [ "$DEEP" = "1" ]; then
  section "DEEP MODE: recently modified files (last 3 days, excluding proc/sys)"
  run "find / -xdev -mtime -3 -type f -not -path '/proc/*' -not -path '/sys/*' -not -path '/var/log/*' 2>/dev/null | head -100"

  section "DEEP MODE: SUID / SGID binaries"
  run "find / -xdev \\( -perm -4000 -o -perm -2000 \\) -type f 2>/dev/null"

  section "DEEP MODE: package integrity"
  run "debsums -c 2>/dev/null | head -50"
  run "rpm -Va 2>/dev/null | head -50"

  section "DEEP MODE: rootkit scanners (if installed — not installed by this script)"
  run "command -v rkhunter chkrootkit 2>/dev/null"

  section "DEEP MODE: logged-in users and last logins"
  run "w"
  run "last -20 2>/dev/null"

  section "DEEP MODE: established outbound connections"
  run "ss -antp state established 2>/dev/null"
fi

section "Done"
echo "Recon complete. This output is read-only evidence — no changes were made to this host."
