# Incident Response Checklist (Workflow C)

## Sequencing rule

Don't touch anything destructive until evidence is collected and a remediation plan has been proposed and confirmed. Evidence collection is read-only, full stop.

## Evidence-collection commands

- Process list with full command lines (`ps auxww`), sorted by CPU/memory for anomaly spotting.
- Listening ports and established connections (`ss -tulpn`, `ss -antp`).
- Cron jobs (`crontab -l` per user, `/etc/cron.*`) and systemd timers (`systemctl list-timers`).
- Recently modified files outside expected paths (`find / -mtime -N -type f` scoped sensibly, e.g. excluding `/proc`, `/sys`).
- Package integrity check (`debsums` on Debian/Ubuntu, `rpm -Va` on RHEL family) to spot modified system binaries.
- Auth log review (`/var/log/auth.log` or `/var/log/secure`) — failed login counts, source IPs, timing patterns.
- Currently logged-in users (`w`, `last`).
- Unexpected SUID/SGID binaries (`find / -perm -4000 -o -perm -2000`).
- `~/.ssh/authorized_keys` for every user account — flag any entry the user doesn't recognize.
- Outbound connections to unfamiliar IPs, cross-referenced against process list.
- Rootkit scanner output if installed (`rkhunter`, `chkrootkit`) — run if available, don't install new scanning tools mid-incident without asking first.
- Kernel and key package versions checked against known CVEs relevant to the host's exposed services.

## Indicators of compromise (IOC) checklist

- Unexpected cron/systemd timer entries.
- Unfamiliar SUID binaries.
- Hidden files/directories in unusual locations (`.` prefixed outside normal dotfile locations).
- Unusual outbound connections (especially to non-standard ports or known-bad IP ranges).
- Unknown user accounts or unexpected members of `sudo`/`wheel`.
- Modified system binaries (flagged by the package-integrity check).
- Webshells in web roots — look for recently modified/added files in the web server's document root, especially ones with eval/exec-style PHP or unusual naming.
- Resource-usage spikes with no legitimate explanation.
- Unauthorized entries in any `authorized_keys` file.

## Rootkit-detection tool notes

- `rkhunter` and `chkrootkit` are useful signals but have real false-negative rates against a sufficiently sophisticated rootkit — a clean scan is evidence, not proof, of an uncompromised host. Say this explicitly in the findings report rather than treating a clean scan as conclusive.

## Severity triage decision tree

- **Low/unclear severity, contained scope** (e.g. a single suspicious cron entry, no evidence of lateral movement or privilege escalation) → in-place remediation is reasonable: propose the specific removal/cleanup action and confirm.
- **High severity or unclear scope** (rootkit indicators, unexplained root-level access, unclear how the attacker got in, evidence of persistence mechanisms) → bias toward **isolate → snapshot for forensics → rebuild from a known-good image/IaC** over in-place cleanup. State explicitly: in-place cleanup of a rootkitted host is unreliable because you can't fully trust the tools you'd use to verify the cleanup worked.

## Remediation-proposal template

For each finding: **Evidence** (what was found, where) → **Proposed action** (quarantine/kill/delete/rotate/rebuild) → **Risk if not done**. Present the full list before executing anything, and get confirmation per action once approved — not one blanket yes for the whole list.

## Isolate + snapshot + rebuild playbook

1. Propose taking the host off the load balancer / out of DNS rotation (hand off — this is provider/DNS-console territory).
2. Propose a forensic snapshot before any other action, so evidence survives even if rebuild happens quickly.
3. Stand up a replacement from a known-good image or IaC definition, rather than trying to fully trust the compromised host again.
4. Once the replacement is verified healthy, propose decommissioning the compromised host (still hand off actual termination if it's a billed/provider-console action the user should explicitly approve).
5. Feed findings back into `hardening-checklist.md` — the same class of gap that allowed this compromise should get closed on the rebuilt host.

## Legal / notification considerations

- If the finding suggests customer data may have been exposed, say so plainly and recommend the user involve legal/compliance before any public communication or regulatory notification — this skill does not draft breach notifications or make that call.
