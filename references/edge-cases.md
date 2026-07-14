# Edge Cases

## Lockout / no-SSH-access recovery

- Before any `sshd_config` or firewall change, confirm a second, already-open SSH session exists as a safety net — if the change breaks SSH, that session is the way back in.
- Document the provider's out-of-band console access as the fallback: AWS EC2 Instance Connect / EC2 Serial Console, Lightsail browser-based SSH, DigitalOcean Droplet Console. Point the user at the right one for their provider before making a risky SSH-affecting change.

## Non-standard SSH port / bastion / jump host

- Detected in Step 0 via `~/.ssh/config` (`ProxyJump`/`ProxyCommand`, non-default `Port`).
- A bastion/jump host is itself possibly shared infrastructure other people depend on — treat changes that touch the bastion itself with the same "might be production" caution as any other host, not extra leniency because it's "just a jump box."

## Existing production workloads

- Ask about maintenance windows before disruptive changes.
- Prefer additive/canary firewall changes (add a rule, verify, then tighten) over wholesale replacement of the rule set.
- Confirm a rollback plan exists before each destructive step, not just before the batch as a whole.

## Containerized targets (Docker / Kubernetes)

- Host-level hardening (SSH, OS firewall, kernel/sysctl, patching) still applies to the underlying VM regardless of what's running in containers on it.
- Service-level changes should go through container restart/redeploy, not direct in-container file edits that will vanish on the next deploy.
- For Kubernetes nodes specifically: don't naively bounce node-level services that could evict pods without warning — check what's scheduled first.
- Deep cluster-level hardening (RBAC, network policies, pod security standards) is adjacent but distinct from this skill's scope — point at the CIS Kubernetes Benchmark rather than freelancing it here.

## Compliance-sensitive environments (PCI / HIPAA / SOC2)

- Recommend a qualified assessor for certification-grade work.
- Point at the `operations:compliance-tracking` skill for ongoing control tracking.
- General best-practice hardening from `hardening-checklist.md` is fine to apply, but say explicitly that it is not a certified compliance implementation on its own.

## IPv6-only / dual-stack hosts

- Firewall rules and service-binding checks (Workflow B) must cover both stacks — a dual-stack host with only an IPv4 firewall rule is effectively half-open.

## Air-gapped / restricted-egress hosts

- Detected in Step 0 via an early mirror-reachability check, not discovered mid-install.
- Ask whether an internal/offline package mirror exists rather than assuming internet access is available.

## Fleet auditing (multiple hosts at once)

- Routes to the `server-recon` subagent, fanned out one instance per host in parallel, explicitly isolated from each other.
- Aggregate results into one severity-sorted report rather than N separate reports.
- A finding that shows up across the entire fleet is likely a base-image/golden-AMI issue worth fixing upstream, not N independent host-level bugs — flag it as such.

## Snapshot / backup before a risky change

- Recommended before any batch of hardening or remediation actions, with the exact provider command/console path given.
- Never auto-performed — it creates a billed resource in the user's account, so it's a confirm-first action like any other in that tier.

## Windows Server targets

- This skill is Linux-primary; Windows Server coverage is intentionally light/secondary.
- Access is WinRM/RDP or OpenSSH-on-Windows rather than classic SSH; patching is Windows Update/WSUS rather than apt/dnf; firewall is Windows Firewall rather than ufw/firewalld.
- For anything beyond basic patching/firewall/account hygiene on a Windows target, recommend the user seek deeper Windows-specific expertise rather than this skill freelancing it.

## Fresh-vs-multi-tenant disambiguation

- Step 0 / recon must always check for pre-existing services, users, and cron entries before trusting a claim that a box is "blank" — surface any discrepancy to the user rather than silently overwriting what's already there.
