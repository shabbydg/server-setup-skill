# Safety Boundaries

The canonical three-tier action list for this skill's domain. `SKILL.md` links here instead of re-deriving these per workflow — Workflows A/B/C reference this file rather than restating it.

## Regular tier (no confirmation needed)

- All read-only recon and investigation commands (Step 0 detection, `scripts/recon.sh`, Workflow C evidence collection).
- Installing exactly the package(s) the user explicitly asked for — scoped, requested, and reversible via uninstall.
- Reading configs, logs, package lists.
- DNS lookups.
- Cloud-metadata endpoint reads, **except** any credential-bearing path (e.g. AWS IAM role temp-credentials).

## Confirm-first tier (ask before every instance, not just the first)

Every item listed under "Always stop-and-confirm" in Workflows A, B, and C in `SKILL.md`. Consolidated:

- Firewall/iptables/ufw/nftables rule changes.
- `sshd_config` edits.
- Restarting or stopping any service that might already be live.
- File deletion or quarantine.
- Killing any process.
- Package removal (installing what was asked for is regular tier; removing anything is confirm-first).
- Creating/deleting user accounts, rotating keys.
- Blocking an IP via the OS firewall.
- Snapshot/backup **creation** — it's a billed resource in the user's account, so even though it's non-destructive, it needs a yes.

A prior approval never carries forward automatically to a different action later in the conversation, even a similar-looking one. Ask again, every time, for the specific action about to run.

## Never tier (hard refusal, not a confirm gate — restating from this session's standing instructions in this domain's terms)

- Modifying AWS Security Groups, DigitalOcean Cloud Firewalls, or IAM policies/roles directly — always hand off to the provider console with the exact path.
- Accepting, storing, displaying, or using plaintext passwords, API keys, or SSH private key material that the user pastes into chat. Ask them to have `aws configure` / `doctl auth init` / an SSH agent already set up locally instead.
- Bulk deletion or bulk remediation without a prior itemized proposal the user has explicitly signed off on.
- Treating an earlier "yes, go ahead" as authorization for a later, different destructive action.

## The one deliberate nuance between confirm-first and never

Disabling the OS-level firewall or opening SSH to `0.0.0.0/0`, when the user explicitly asks for it on their own box, is **confirm-first with an explicit risk warning and a safer alternative offered** — not a never-tier refusal. Reasoning: it's the user's own single-tenant resource, not access control on shared/collaborative infrastructure (unlike a Security Group, which can affect other resources in the same VPC, or an IAM policy, which affects account-wide access). State the specific risk (e.g. "this exposes SSH to unauthenticated internet-wide scanning and brute force"), suggest a narrower alternative (restrict to a known IP, keep fail2ban running), and require a standalone, explicit re-confirmation before executing — comply if the user still wants it after hearing the risk, don't just refuse outright.
