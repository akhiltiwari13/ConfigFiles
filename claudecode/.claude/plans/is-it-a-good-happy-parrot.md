# GitHub clone fails for Alkimi org — SSH key routing fix across 3 boxes

## Context

User is setting up the K10 box (Ubuntu, hostname `sambhav-NucBox-K10`, located miles away in a friend's garage) and can't clone `git@github.com:Alkimi-Exchange/MMP-CEX-GATE.git`. K10 currently has no local SSH keys — it only sees forwarded keys from a primary box.

The other two machines (omarchy-tp, Mac Air) already use per-machine keys (each box has its own ed25519 keypair, with the corresponding `.pub` enrolled separately under the same two GitHub identities). K10 needs to be brought up to the same standard.

Constraint: setup must work identically across all 3 boxes via the existing stow workflow.

## Diagnosis (settled)

GitHub identifies users by SSH key, not by username. K10's agent has both a personal and a work key forwarded; ssh offers them in agent-order; GitHub authenticates the personal one first; that account can't see the Alkimi private repo; GitHub returns `Repository not found` (it deliberately won't say "permission denied" for private repos).

`git config` and `includeIf` only set commit author email — they don't influence which SSH key is presented. Key selection is entirely controlled by ssh-agent + `~/.ssh/config`.

The existing `Host github-work` alias has `IdentityFile ~/.ssh/id_ed25519_kensalt` but no `IdentitiesOnly yes`. Without that directive, `IdentityFile` is treated as an *additional* key on top of the agent's offerings, not a restriction. So even cloning via `git@github-work:...` still presents the personal key first.

## Why K10 should generate its own keys (not rely on forwarding)

Agent forwarding is fine for transient SSH sessions but unsuited to a persistent dev box:

1. **Long-lived tmux sessions break forwarding.** New SSH session = new agent socket path. Existing tmux panes keep a stale `SSH_AUTH_SOCK`; git operations inside them fail until you manually re-export the new socket.
2. **Unattended jobs can't reach the forwarded agent.** Cron, systemd timers, builds that outlast your session — all dead.
3. **Latency.** Every signature round-trips to your laptop.
4. **Compromise scope is actually narrower with per-machine keys.** A leaked K10 key is revocable in isolation. A forwarded-agent hijack on a compromised K10 lets an attacker authenticate as your full identity to anywhere your laptop's keys reach — strictly worse blast radius.

## Why we don't commit `.pub` files in this topology

Per-machine keys means each box's `.pub` content differs. Can't put three different `id_ed25519.pub` files at the same stow path. The other two boxes already keep keys local and only stow `~/.ssh/config` — K10 needs to follow the same pattern.

## Plan

### Repo edits (one-time, benefits all 3 boxes)

**`ssh/.ssh/config`** — add `IdentitiesOnly yes` to both Host blocks:

```
Host github
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    IdentitiesOnly yes

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_kensalt
    IdentitiesOnly yes
```

**`README.md`** — under the "Bootstrapping a new machine" / "First-time setup on a fresh box" section, add a step:

> Generate two ed25519 keypairs and enroll their `.pub` files with the respective GitHub identities:
> ```bash
> ssh-keygen -t ed25519 -C "akhiltiwari.13@gmail.com" -f ~/.ssh/id_ed25519
> ssh-keygen -t ed25519 -C "akhil@kensaltensi.org"     -f ~/.ssh/id_ed25519_kensalt
> # Enroll ~/.ssh/id_ed25519.pub under github.com/akhiltiwari13
> # Enroll ~/.ssh/id_ed25519_kensalt.pub under the Alkimi-org-linked account
> ```

### K10-specific one-time setup (manual, after pulling repo updates)

1. Pull and restow on K10:
   ```bash
   cd ~/Work/projects/quomptrade/configfiles && git pull
   stow -R ssh
   ```
2. Generate the two keypairs (commands above).
3. Add to local agent: `ssh-add ~/.ssh/id_ed25519 ~/.ssh/id_ed25519_kensalt`.
4. Enroll both `.pub` files via the GitHub web UI.
5. **Disable agent forwarding for K10** when sshing in (or at least for github operations) — otherwise the agent will have 4 keys (2 local + 2 forwarded) and `IdentitiesOnly yes` is the only thing keeping ssh from offering the wrong ones. Easiest: drop `ForwardAgent yes` from whichever ssh config entry you use to reach K10.

### Optional polish (separate, can defer)

In `gitconfig/.gitconfig` (top-level, applies regardless of cwd because `includeIf gitdir:` doesn't fire during `git clone`):

```
[url "git@github-work:Alkimi-Exchange/"]
    insteadOf = git@github.com:Alkimi-Exchange/
```

So pasting `git@github.com:Alkimi-Exchange/<repo>.git` from GitHub's clone-URL UI still routes through the work alias.

## Files to be modified

- `ssh/.ssh/config` (add 2 lines)
- `README.md` (add a paragraph under "First-time setup on a fresh box")
- `gitconfig/.gitconfig` (optional, ~3 lines)

## Verification

After the repo change is pulled and restowed on each box, and (on K10 only) keys are generated and enrolled:

```bash
# Identity check — should now report the right account per alias
ssh -T git@github            # → Hi akhiltiwari.13!
ssh -T git@github-work       # → Hi <work-handle>!

# Clone via the work alias
cd ~/Work/projects/alkimi
git clone git@github-work:Alkimi-Exchange/MMP-CEX-GATE.git cex
cd cex
git config user.email        # → akhil@kensaltensi.org (from existing includeIf)

# If url.insteadOf was added, paste-from-GitHub URLs also work:
git clone git@github.com:Alkimi-Exchange/MMP-CEX-GATE.git cex2
```

Repeat the `ssh -T` and clone tests on omarchy-tp and Mac Air to confirm `IdentitiesOnly yes` doesn't regress anything there (those boxes already have local keys, so it should just enforce what was already happening implicitly).
