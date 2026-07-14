# Hardening Checklist (Workflow B)

Every item here is confirm-gated per action — see `safety-boundaries.md`. This is the checklist to work through, propose item-by-item, not a script to run in bulk.

## SSH

- Key-only authentication (`PasswordAuthentication no`) — only after confirming the user has a working key and a second session stays open as a lockout safety net.
- `PermitRootLogin no`.
- `MaxAuthTries` set low (e.g. 3–4).
- `AllowUsers` / `AllowGroups` to restrict which accounts can SSH in at all.
- Optional: non-default port — genuinely reduces automated scan noise but is not a substitute for the above; don't present it as one.

## Firewall baseline

- Default-deny inbound, allow only the ports the running services actually need.
- Confirm IPv4 and IPv6 rules are both covered — a dual-stack host with only an IPv4 rule set is only half-hardened.
- Note whichever tool Step 0 detected (ufw/firewalld/nftables/none) and use that, don't introduce a second competing firewall layer.

## Automatic security updates

- `unattended-upgrades` (Debian/Ubuntu) or `dnf-automatic` (RHEL family) for security patches specifically — confirm whether the user wants full automatic upgrades or security-only.

## User / account hygiene

- Remove or lock unused accounts.
- Disable password auth for all interactive accounts, not just the one the user SSHes in as.
- Sudo logging enabled (`Defaults log_output` or equivalent) and reviewed as part of the audit workflow.

## Kernel / sysctl network hardening

- Disable IP forwarding unless the host is actually routing traffic.
- Enable SYN cookies, disable ICMP redirects acceptance, enable reverse-path filtering — standard `sysctl` network-hardening set.

## Filesystem permissions

- Tighten world-readable permissions on files containing secrets/config (application `.env` files, private keys, credential files).
- Verify `/etc/shadow` and similar sensitive files have correct restrictive permissions (usually already correct by default — flag if not).

## Attack-surface reduction

- Disable/remove services that aren't actually needed for the box's stated purpose — propose each removal individually with the reason.

## Logging & monitoring

- `auditd` for security-relevant syscall auditing, if the user wants that depth.
- Centralized log shipping (to the user's existing log platform, if any) — don't invent a new one unprompted.
- Log rotation configured so disk doesn't fill silently.

## TLS / app-layer

- Certbot/Let's Encrypt renewal automation if the box terminates TLS.
- Basic nginx/Apache security headers (HSTS, X-Content-Type-Options, etc.) as a proposal, not a silent default.
- Mention ModSecurity/WAF-at-the-app-layer as an option for web-facing hosts, without assuming the user wants that depth.

## Backup / snapshot discipline

- Propose a snapshot before any batch of hardening changes, with the exact provider command/console path — never auto-create it, it's a billed resource in the user's account.

## Secrets hygiene

- No plaintext secrets in world-readable files on disk; point the user at a secrets manager or environment-variable injection pattern if you find any during recon.

## Package integrity

- Verify package signatures/checksums are enabled by default for the distro's package manager (usually already true — flag if disabled).

## Named standards

- CIS Benchmarks are a legitimate deeper standard some users will name explicitly — treat as opt-in, not the default bar. If the user asks for "CIS-compliant," say which specific CIS controls you're applying rather than claiming blanket compliance.
