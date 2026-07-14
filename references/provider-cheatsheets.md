# Provider Cheatsheets

Per-provider notes on what's console-only (never touched directly by this skill) and useful CLI/metadata shortcuts.

**Shared rule across every provider below: never read or print IAM/instance-role credentials from a metadata endpoint.** That applies regardless of which provider the host turns out to be.

## AWS EC2

- **Console-only, hand off:** Security Groups (VPC → Security Groups → inbound/outbound rules), NACLs, IAM roles/policies, Elastic IP association, Route53 DNS, ALB/NLB config, Auto Scaling Groups.
- IMDSv2 requires a token hop (`X-aws-ec2-metadata-token`) — see `environment-detection.md`.
- AWS Systems Manager Session Manager (SSM) is a viable SSH alternative/fallback if the user has it configured — useful for the lockout-recovery case in `edge-cases.md`.
- Console path for the most common hand-off: "AWS Console → EC2 → Instances → (select instance) → Security tab → Security groups → (select group) → Inbound rules → Edit inbound rules."

## AWS Lightsail

- Has its own simplified firewall UI (separate from raw Security Groups, though it's EC2-backed under the hood) — console path: "Lightsail Console → Instance → Networking tab → Firewall."
- Static IP attachment and native snapshot/backup features are built into the Lightsail console directly.
- Browser-based SSH console is available from the Lightsail dashboard as an out-of-band access method if the user gets locked out.

## DigitalOcean

- **Console-only, hand off:** Cloud Firewalls ("Networking → Firewalls"), VPC/private networking config.
- `doctl` CLI (if the user has it authenticated) can inspect droplet metadata and firewall state without this skill needing raw credentials.
- Native snapshot/backup feature available from the Droplet's console page.
- Droplet Console (browser-based) is the out-of-band access method for lockout recovery.

## Generic VPS providers (Hetzner, Vultr, Linode, OVH)

Lower priority given the user's "or any other virtual server" framing — keep guidance light:

- Each has a web console with its own firewall UI and snapshot feature; ask the user to locate it in their specific dashboard rather than assuming exact menu paths.
- Each typically offers an out-of-band browser/VNC console for lockout recovery.

## GCP / Azure

- Mentioned only in passing — not deeply covered by this skill. Metadata endpoint format differs (see `environment-detection.md`); firewall rules (GCP VPC firewall rules, Azure NSGs) are console/CLI-only in the same way as AWS Security Groups.
