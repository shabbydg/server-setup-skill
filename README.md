# Remote Server Ops

A [Claude skill](https://docs.claude.com/en/docs/claude-code/skills) for
configuring, securing, and investigating a remote Linux or Windows server you
already have SSH/RDP access to — a fresh VM or one already in production use.

It covers three workflows: provisioning and configuring a service on a blank
box, hardening an existing server, and auditing/responding to a suspected
compromise. It treats every host as a potential production system until
recon proves otherwise, and it never touches provider-level access controls
(Security Groups, Cloud Firewalls, IAM) or creates the VM itself — those
stay with the user.

## Install

Drop the `server-setup-skill/` folder into your skills directory (e.g.
`~/.claude/skills/` for Claude Code) and it'll be picked up automatically the
next time it's relevant.

## Use

Just ask, once you have SSH access to a host:

> "SSH into my DigitalOcean droplet and set up nginx + postgres."

> "Harden this server before we go live."

> "My server might be hacked — can you check for malware and give me an
> incident report?"

The skill detects the provider and current state of the box, confirms which
workflow applies (provision, harden, or audit/incident-response), and works
through it step by step — handing off anything that requires provider-console
access (Security Groups, IAM, firewalls) with the exact console path.

## What's inside

- `SKILL.md` — the main instructions, covering initial assessment and all
  three workflows
- `references/` — deep-dive docs: hardening checklist, incident-response
  checklist, OS/package-manager map, provider cheatsheets, environment
  detection, edge cases, safety boundaries
- `agents/server-recon/` — a subagent for recon
- `scripts/recon.sh` — a recon helper script
- `evals/` — eval cases for the skill

## License

MIT
