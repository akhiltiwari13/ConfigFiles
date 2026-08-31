# omarchy-tp system-hang: root cause + remediation plan (model-agnostic handoff)

> **Status:** investigation complete + self-critiqued (rev 2). Not yet executed.
> **Purpose:** self-contained — executable by any assistant/model or a human
> without the originating chat.
>
> **Step 0 — make this durable and version-controlled:**
> ```
> mkdir -p ~/Work/projects/quomptrade/configfiles/syshardening
> cp ~/.claude/plans/federated-bubbling-cupcake.md \
>    ~/Work/projects/quomptrade/configfiles/syshardening/PLAN.md
> cd ~/Work/projects/quomptrade/configfiles && git add syshardening/PLAN.md
> ```
>
> **Machine:** ThinkPad E14 Gen 6, Intel Core Ultra 7 155H (6P+8E+2LP = 16C/22T),
> **16 GiB RAM** (15.1 GiB usable), NVMe 476 GiB, BIOS R2JET48W 1.25 (2026-04-27).
> Arch / Omarchy `4.0.0.alpha`, kernel `7.1.9-arch1-2`, **Limine** bootloader,
> root = **LUKS + btrfs** (subvol `@`), **snapper** + `limine-snapper-sync`
> installed (`/.snapshots` exists), sleep = `s2idle` only. Host `omarchy-tp`,
> user `quomptrade` (uid 1000). Dotfiles: `~/Work/projects/quomptrade/configfiles`
> (GNU Stow, target `$HOME`).

---

# PART 1 — ROOT CAUSE

## rev 4 — LEADING CAUSE FOUND: critical-battery suspend → power exhaustion

Going further back through the retained journal (boots -1 … -19) produced a
near-perfect statistical separation that supersedes both earlier candidates.

**Contingency table over 18 classified boots:**

| | ended abruptly | shut down cleanly |
|---|---|---|
| boot used s2idle suspend | **9** | 1 |
| boot never suspended | **0** | 8 |

Boot -3 ran **2.7 days** without suspending and shut down cleanly. Not one boot
that never suspended ever froze.

**And the suspends are not ordinary ones.** In **8 of the 9** abrupt boots the
final suspend was logged as:
```
systemd-logind[…]: suspend requested from client PID … ('upowerd') (unit upower.service)
kernel: PM: suspend entry (s2idle)
```
`upowerd` requesting suspend is **UPower's critical-battery action**. The one
clean boot that did suspend (-17, 3 resumes) had **zero** upowerd-requested
suspends — its suspends came from lid/idle.

**Config confirms the trigger** (`/etc/UPower/UPower.conf`):
```
UsePercentageForPolicy=true
PercentageAction=2.0          ← act at 2% battery
CriticalPowerAction=Auto      ← "Auto" = hibernate if available, else SUSPEND
AllowRiskyCriticalPowerAction=false
```
**Hibernation is not configured on this machine** (no swapfile, no `resume=`), so
`Auto` degrades to **Suspend**. The machine therefore suspends to s2idle at 2%
battery — and s2idle ("modern standby") on Meteor Lake keeps drawing power.

**Time-to-death matches the remaining charge almost exactly.** Battery is 44.1 Wh
full, so 2% ≈ **0.9 Wh**. At a typical 15–25 W that is ~2–4 minutes of life.
Measured gap from resume to the end of the journal:

| boot | gap | | boot | gap |
|---|---|---|---|---|
| -18 | **2.2 min** | | -13 | 13 min |
| -15 | **3.7 min** | | -7 | 17 min |
| -14 | **3.8 min** | | -4 | 27 min |
| -10 | **5.8 min** | | -1 | 7 h 19 m (no upowerd suspend) |
| -16 | **6.7 min** | | | |

Every suspend→resume interval was **under 60 seconds** — the machine suspended at
2% and bounced straight back awake, then ran until the charge was gone.

**Battery exhaustion was considered and is RULED OUT for most cases.** User
testimony (2026-08-31): the hangs present as *"mostly frozen screens with the time
not getting updated (as verified in the top bar)"*, and **"power button alone
works"** — no charger needed to bring it back. A flat battery gives a black, dead
screen and cannot be restarted without AC. A lit display holding a stale frame,
recoverable on battery, means **the machine is powered and wedged.** Only the most
recent event (boot -1) presented as *"black/dead screen and was on battery"*.

**Corrected mechanism (rev 5): s2idle suspend/resume instability.** The
association with suspend stands — it is the single strongest signal in the data —
but the failure is a **wedge after resume, not power loss**:

1. Battery reaches 2% → `upowerd` forces an emergency s2idle suspend.
2. The suspend/resume cycle completes in **under 60 s** (it suspends and bounces
   straight back awake) but leaves something in a broken state.
3. The machine runs 2–27 minutes, then **hard-freezes with the display holding a
   stale frame**, still powered.
4. A long power-button press is required; it boots normally afterwards.

This fits every observation: frozen-but-lit screen, recovery on battery alone, no
logs (journald can't write), no OOM / thermal / NVMe / hung-task, and the perfect
suspend↔freeze correlation. The critical-battery path is an emergency, rarely
exercised code path taken at an unusual SoC power state — a plausible place for a
Meteor Lake s2idle bug to bite.

### Peripheral topology (rev 5 — materially changes the input reasoning)

The machine is **normally used docked**: 2× BenQ GW3290QT external monitors,
a **Logitech USB mechanical keyboard**, and a Logitech **Bluetooth** mouse (the
Bluetooth radio is itself a USB device, `8087:0033` on bus 3). A Thunderbolt/USB4
domain is present (`/sys/bus/thunderbolt/devices/domain0`).

**This voids an argument made in rev 3.** rev 3 reasoned that because the internal
keyboard is PS/2 (`isa0060/serio0`), a wedged xhci could not explain dead input.
That is true only for the *internal* keyboard — which is not what is normally in
use. With a USB keyboard and a USB-attached Bluetooth mouse, **a USB/xhci wedge
kills the entire input stack**, and a wedged USB-C/DP link freezes the external
displays on their last frame. The USB hypothesis is back in play.

**Dock state at each freeze** (Logitech/BenQ presence in the boot):

| boot | docked | last BenQ event before freeze |
|---|---|---|
| -4 | **yes** | **0 min** — BenQ USB churn *at* the freeze |
| -15 | yes | 216 min (**30,270** BenQ log lines that boot) |
| -13 | yes | 320 min |
| -10 | yes | 193 min |
| -14 | yes | 113 min |
| -7 | yes | 385 min |
| -1, -16, -18 | **no** | — (never docked) |

Docked in **6 of 9**, so docking is **not necessary** — boots -16 and -18 were
undocked, had upowerd suspends, and still died. The critical-battery suspend
remains the only factor present in 8 of 9.

**Separately: the dock/monitor USB link is genuinely flaky.** 3,380 BenQ-related
kernel lines in boot -4 and **30,270** in boot -15 are event storms, not normal
enumeration (clean boots run 68–526). Worth chasing on its own — cable, port, or
hub — regardless of the freeze question.

**Prime suspect for the wedge: i915 / GuC.** Every resume in the logs reloads GuC
and HuC firmware (`mtl_guc_70.bin`, `mtl_huc_gsc.bin`, "GUC: submission enabled",
"SLPC enabled"). A GPU wedge would freeze the display on a stale frame exactly as
described — while the kernel underneath may still be alive. Secondary suspect:
the Goodix reader failing USB resume and blocking the PM resume path.

**This is directly testable — see Phase 0d.** If the kernel is alive behind a
wedged GPU, SSH and SysRq will still work. That single test discriminates
"GPU/compositor wedge" from "whole-kernel wedge" and would settle the diagnosis.

**Boot -1 (2026-08-31)** remains distinct — no upowerd suspend, froze 7 h after
its last lid/idle resume during the idle screen-lock, presented as a black screen
on battery, and carried the peak Goodix reset count (851). It may be a second
failure mode.

**This also rescues the "it happens during builds" account:** a long build keeps
the machine awake and draining; nothing inhibits the critical-battery action; the
user walks away, and returns to a dead/wedged machine mid-build.

### What changes in the plan

1. **Phase 0d (the next-freeze test) is now the single most valuable action.**
   Everything else is a guess until we know whether the kernel survives the wedge.
2. **Phase 1a (`omarchy-hibernation-setup`) becomes the primary *fix*, for a
   completely different reason than rev 1–3 gave.** With a hibernation swapfile
   present, `CriticalPowerAction=Auto` resolves to **Hibernate** instead of
   Suspend — removing the emergency s2idle path that precedes 8 of 9 deaths.
   (rev 1–3 wanted this swapfile for anti-thrash headroom. That reasoning was
   weak; *this* reason is strong. Same action, right justification.)
3. **Raise the action threshold** so hibernate has time to complete:
   `syshardening/etc/UPower/UPower.conf.d/10-local.conf` →
   `PercentageAction=5.0`, `PercentageCritical=10.0`. At 2% there is ~0.9 Wh
   (~2–4 min) of margin — not enough to write a 16 GB hibernation image.
4. **Consider suppressing the failing path outright** while testing: set
   `CriticalPowerAction=PowerOff`, or (blunter) mask suspend entirely
   (`sudo systemctl mask sleep.target suspend.target`) for a week. If the deaths
   stop, the diagnosis is confirmed with certainty. This is the cleanest
   experiment available and costs only the convenience of suspend.
5. **Memory/zram work (Candidate A) drops to LOW priority.** Still a genuine
   fragility worth fixing eventually; it is **not** what has been killing this
   machine, and rev 1–3 were wrong to lead with it.
6. **Build caps (Phase 2) drop to routine hygiene** — worth doing, unrelated to
   the crashes.
7. **Goodix udev fix stays** — cheap, correct, and now doubly relevant: a USB
   device that fails to resume can block the PM resume path.
8. **i915/GuC becomes a named suspect.** If 0d shows SSH works during a freeze,
   pursue: kernel `i915.enable_dc=0` / `i915.enable_psr=0` test, a BIOS update
   (current R2JET48W 1.25), and `linux-lts` as a comparison kernel.

---

## Superseded: TWO candidate causes, neither proven (rev 3)

> **rev 3 correction.** rev 2 declared memory-reclaim livelock the root cause with
> "high confidence". **That is not supportable.** A per-boot forensic pass over the
> three abrupt shutdowns in the retained window found a second, independent
> anomaly, and found that the one *confirmed* memory-pressure event did **not**
> freeze the machine. Both candidates below are real and worth fixing; neither is
> necessary nor sufficient on the evidence, and one freeze fits neither.

Verified directly (checking for a shutdown sequence, not `last -x`): of the 7 most
recent boots examined, **3 ended abruptly** — boot **-1** (2026-08-31 08:34:41),
boot **-4** (2026-08-23 18:56:59), boot **-7** (2026-08-20 18:23:43). Boots -3,
-5, -6, -8 shut down cleanly. (rev 2 repeated a "~30 crash boots" figure derived
from `last -x`; that command flags sessions as "crash" for reasons beyond hard
reboots and should not be used as the count.)

**Candidate A — memory-reclaim livelock** (structural; see Mechanism below).
**Candidate B — Goodix fingerprint reader USB reset loop** (see Evidence B).

**Neither explains boot -7**, which froze while idle with no reset loop and no
memory-pressure event.

## Mechanism

Conditions, all currently true:

1. **16 GiB RAM**, with a **~6–8 GiB desktop baseline** (Chromium multi-process,
   multiple `claude` sessions, quickshell, 1Password, Dropbox, tailscale, voxtype
   holding a ~2 GiB Whisper model).
2. **Swap is zram-only** (`/dev/zram0`, ceiling 15.1 GiB, zstd, priority 100).
   **No disk-backed swap exists** — no `/swapfile`, no `resume=` on cmdline.
3. **Uncapped parallel C++ builds** — see appendix. The documented "6 cores max"
   rule is never actually exported anywhere.

zram lives *inside RAM*. To reclaim an anonymous page the kernel must compress it
and **allocate a page to hold the compressed copy — which itself needs free RAM.**
Once anonymous demand drives free memory below the kernel's watermarks, that
allocation fails, so `kswapd` and every allocating task spin in reclaim making no
forward progress. All 22 threads go to ~100% system CPU doing zstd; I/O saturates;
**userspace stops being scheduled**. Because allocations keep *nominally*
succeeding through zram, the **kernel OOM killer never fires**, and `systemd-oomd`
(needs 20 s sustained >50% pressure, only allowed to kill `app.slice`) is itself
starved before its window elapses. Nothing breaks the loop.

## Evidence

- **Boot -2, 2026-08-26 19:52:14** — the mechanism caught mid-episode (recovered):
  ```
  kswapd0: page allocation failure: order:0, mode:0xc0de0(GFP_KERNEL|__GFP_HIGH|__GFP_ZERO|__GFP_COMP|__GFP_NOMEMALLOC)
    __alloc_pages_slowpath → folio_alloc_swap → cluster_alloc_swap_entry
    → shrink_folio_list → evict_folios → balance_pgdat → kswapd
  Node 0 Normal free:27276kB  min:60132kB  low:236080kB
  Free swap = 13435108kB   Total swap = 15818748kB     ← swap only ~15% used
  ```
  **Swap was not full.** The allocation that failed was the RAM needed to compress
  a page *into* zram. A `conan … conftest` SIGABRT coredump at **19:48:56**
  (3 min earlier) places `conan install --build=missing` (boost/folly/abseil on
  all 22 cores) right at the scene.
- **Boot -1, the hard reboot (ends 2026-08-31 08:34:41)** — journal stops dead
  mid-operation during the idle screen-lock (`omarchy idle … lock-timeout` →
  `Starting Fingerprint Authentication Daemon` → `usb 3-6: reset … xhci_hcd` →
  *silence*). No shutdown target, no error, no OOM, no hung-task, no thermal trip:
  journald could not flush because I/O was starved. Earlier that evening: 4×
  `perf: interrupt took too long` (17:37–21:17) = sustained all-core load.
- **Full journal scan 2026-06-29 → present:** ZERO nvme timeout/reset, ZERO
  `GPU HANG`/i915 reset, ZERO thermal critical trip, ZERO rcu-stall/soft-lockup/
  hung-task, ZERO `invoked oom-killer`. Rules out disk-firmware, GPU, driver
  deadlock.
- **Secondary flag:** boot 0 carries an ACPI `BERT: [Hardware Error] … Total
  records found: 1`. Firmware routinely writes a generic "unexpected reset" BERT
  record after a hard power-off, so probably benign — but `thermald` is **dead**
  on this CPU ("Unsupported cpu model", Meteor Lake), the power profile is pinned
  to `performance`, and package temp is ~80–82 °C at ~0.4 load. Cheap to decode;
  do it early (Phase 4b) since a positive result would redirect everything.

## Evidence B — Goodix fingerprint reader USB reset loop

`usb 3-6` = **Goodix `27c6:659a`** ("Goodix USB2.0 MISC", `goodixmoc` driver,
serial `UID3E599426_XXXX_MOC_B0`). It is a working, **enrolled** sensor
(`fprintd-list` → "Goodix MOC Fingerprint Sensor (press)", `#0: right-index-finger`)
and Omarchy's lock screen authenticates against it (PAM config
`omarchy-lock-fingerprint`).

It is in a **continuous USB reset loop**:

| boot | outcome | `usb 3-6` resets | all other devices |
|---|---|---|---|
| **-1** | **abrupt** | **851** | 0 |
| -3 (2.7 days) | clean | 12 | — |
| **-4** | **abrupt** | **469** | 0 |
| -5, -6 (short) | clean | 6, 8 | — |
| **-7** | **abrupt** | **0** | 0 |
| -8 (~22 h) | clean | 4 | — |
| **0 (now)** | running | **734 in ~13 h** | 0 |

Every reset in every boot targets `3-6` and nothing else. Rate in boot -1 was
~118/hour, sustained from 01:00 straight through the 08:34 freeze.

**Boot -1's final kernel line is one of these resets**, at 08:34:41 — immediately
after `Starting Fingerprint Authentication Daemon`, i.e. the moment the idle lock
screen opened the device. Boot -4's final lines are the two BenQ monitors' USB
HID devices connecting and disconnecting 7 s before the freeze, in a boot that
also carried 469 fingerprint resets.

**Mechanism:** `power/control = auto` with `autosuspend_delay_ms = 2000` (global
`usbcore.autosuspend = 2`), **no udev rule** for `27c6:*`. The device suspends
after 2 s, fails to resume cleanly, and xhci issues a port reset — repeatedly.
`runtime_active_time` is ~5.9 h of ~12.6 h uptime for a sensor that should be
idle almost always. Goodix readers are widely known for exactly this
resume/reset failure on Linux.

## Confidence — honest assessment

**Neither candidate is established.** What the evidence actually shows:

- **Against A (memory):** the *only* confirmed memory-pressure event in the whole
  retained journal — boot -2, 2026-08-26 19:52:14, `kswapd0: page allocation
  failure` — occurred in a boot that **ended cleanly four days later**. Memory
  pressure demonstrably did not wedge this machine that time.
- **Against B (USB):** boot -7 froze with **zero** resets, so the loop is not
  necessary. The loop is **active right now** (734 resets, 13 h, no freeze), so it
  is not sufficient. And the internal keyboard is `AT Translated Set 2 keyboard`
  on `isa0060/serio0` — **PS/2, not USB** — so a wedged xhci would not by itself
  explain total input death.
- **Against the stated trigger:** the user reports freezes "almost always when I
  build". In this window **2 of 3 froze while idle** (idle screen-lock; monitor
  unplug) and none has a build running at the moment of the freeze. Either the
  build correlation is recall bias, or a build-triggered freeze simply isn't in
  the retained window.

**What is solid:** both A and B are genuine defects worth fixing on their own
merits. **What is not solid:** that either one causes the freezes.

**The real problem is that every freeze leaves no evidence.** journald cannot
flush during the wedge, so all three abrupt boots end in silence. Guessing harder
will not fix this. **Phase 0 is now primarily about making the *next* freeze
diagnosable** (see 0c), not about tuning.

## "Was the OS recording my keystrokes? Why no response?"

**No keylogger is installed or running.** The only text-injection tool present is
`voxtype` — a **microphone** push-to-talk voice-to-text daemon. It never reads the
keyboard and was idle at freeze time.

During the hang the kernel keeps receiving keypresses and buffering them: each
open input device has a small fixed-size `evdev` ring buffer, drained by
`libinput` inside Hyprland. When Hyprland gets no CPU (or blocks in major page
faults waiting for its own pages back from zram) it never drains the buffer;
within ~1–2 s it fills, the kernel emits `SYN_DROPPED` and **discards** the rest.
Nothing is written to disk — what you typed sat briefly in a RAM ring buffer and
was lost at power-off. It "didn't respond" because the process that turns key
events into pixels got no CPU. Magic-SysRq couldn't rescue it either:
`kernel.sysrq = 16` (sync only — the OOM-kill `+f` and reboot `+b` bits are
**off**), and `kernel.hung_task_panic = 0` / `kernel.softlockup_panic = 0`.

---

# PART 2 — CONCEPTS

- **OOM** — *Out Of Memory*. The **OOM killer** is the kernel's last resort: kill
  one process to save the rest.
- **swap** — overflow space for RAM.
- **zram** — a compressed block device *in RAM*, used as swap. Pages are
  compressed (zstd, measured **2.8:1** on this box) and kept in RAM rather than
  written to disk. Fast, no SSD wear, **but consumes RAM** and burns CPU.
- **zram `disksize` is a ceiling, not a reservation.** Measured here: `DISKSIZE
  15.1G, DATA 768.1M, COMPR 271M, TOTAL 284.4M` — it is holding 768 MB of pages in
  284 MB of real RAM. It allocates lazily. **Changing `disksize` frees no RAM.**
  (This corrects a wrong claim in rev 1 of this plan.)
- **disk swapfile** — a file on the SSD used as swap. Slower than zram, but
  genuinely *extra* capacity costing **zero RAM**, and paging a page out to it
  needs **no memory allocation** — which is precisely what breaks the livelock.
- **swap priority** — higher number is used **first**, and a lower-priority device
  is only touched when the higher one is **full**. So zram(100) + swapfile(0)
  means the disk is a *last resort*, not a parallel path. This matters for the
  zram-sizing question (Phase 3a).
- **systemd-oomd** — userspace daemon that watches memory *pressure* (PSI: time
  spent stalled on memory) and kills proactively, before the kernel OOM killer
  (which only acts *after* an allocation already failed). Active here but tuned
  leniently and has never fired.
- **PSI** (`/proc/pressure/memory`) — `some`/`full` × avg10/60/300: the % of time
  tasks were stalled waiting on memory. The single best live indicator.
- **build parallelism** (`-j N`) — how many compilers run at once. Each is ~1–2 GB
  RAM; **LTO linkers are far more**. 22 threads visible; safe cap here is ~6.
- **cgroup `MemoryHigh` / `MemoryMax`** — per-process-group limits. `High` =
  soft (throttle via reclaim, process slows). `Max` = hard (that group's OOM
  killer fires — kills the compiler, not the desktop).
- **MGLRU `min_ttl_ms`** — if reclaim can't keep the working set younger than this,
  declare OOM. Converts a silent thrash into a fast, *logged* kill. Aggressive
  values cause more OOM kills — that is the intent, but it surprises people.
- **`syshardening/`** — a **new folder in the dotfiles repo, not a stow package**
  (its files go in `/etc/`, which stow can't reach; stow targets `$HOME`). Holds
  mirrored `/etc` drop-ins + an idempotent `install.sh`. Each drop-in *overrides*
  an Omarchy default without editing it; delete one file to undo one change.

---

# PART 3 — REMEDIATION PLAN

Legend: **[repo]** commit to dotfiles · **[sys]** system change, needs `sudo` ·
**[user]** human runs interactively.

Ordering principle: **do the things that can only help first, measure second,
tune third.** Phases 1 and 2 are safe and directly address the failure path.
Phase 3 contains the judgement calls that should be driven by Phase 0 data.

## Repo changes map

| Path | Type | Change |
|---|---|---|
| `bash-omarchy/.bashrc` | [repo] | guarded global build-parallelism env exports |
| `omarchy-overrides/.config/bin/membuild` | [repo] new, `chmod 755` | memory-capped build wrapper |
| `omarchy-overrides/.config/bin/psi-warn` | [repo] new, `chmod 755` | early-warning notifier |
| `omarchy-overrides/.config/systemd/user/{build.slice.d/oomd.conf,psi-warn.service,psi-warn.timer}` | [repo] new | oomd coverage + notifier units |
| `conan/.conan2/global.conf` | [repo] **new stow package** | `tools.build:jobs=6` |
| `scripts/bootstrap.sh` | [repo] | add `conan` to `OMARCHY_PKGS`, `MACAIR_PKGS` |
| `voxtype/.config/voxtype/config.toml` | [repo] | `on_demand_loading = true` |
| `syshardening/etc/**` + `syshardening/install.sh` | [repo] **new non-stow dir** | `/etc` drop-ins + installer (`--uninstall` supported) |
| `CLAUDE.md` / `AGENTS.md` | [repo] | document `syshardening/`, swapfile, makepkg.d, `conan` pkg, SysRq recovery |

---

## Phase 0 — Measure before tuning  [user]

The crash boot left no trace, and three Phase-3 knobs are judgement calls that
should be sized from data, not guessed. This is ~30 min and de-risks everything.

**0a. Instrument a real heavy build** (do this *after* Phase 1a+1c, so the disk
swapfile and SysRq rescue are already in place as a safety net):
```
# pane A — sample every 2s to a log
while :; do
  printf '%s ' "$(date +%T)"
  awk '/^some/{printf "psi_some=%s ", $2}' /proc/pressure/memory
  free -m | awk '/^Mem:/{printf "used=%s avail=%s ", $3,$7}'
  awk '{printf "zram_ram_mb=%d\n", $3/1048576}' /sys/block/zram0/mm_stat
  sleep 2
done | tee ~/build-pressure-$(date +%F-%H%M).log

# pane B — the heaviest native build, with per-process accounting
cd ~/Work/learn/quant-research/pqr/reseachr00
/usr/bin/time -v ./build.sh Release 2>&1 | tee ~/build-rss-$(date +%F-%H%M).log
```
**Record:** peak `used`, minimum `avail`, peak `psi_some`, peak zram RAM, and —
critically — **`Maximum resident set size` of the largest single process** (the
LTO link step). `systemd-cgtop -m` in a third pane is a good live view.

**0d. THE ONE TEST THAT SETTLES IT — do this at the next freeze.** [user]

The next time the screen freezes with a stale clock, **before** touching the power
button, in this order:

0. **Use the INTERNAL laptop keyboard, not the Logitech USB one.** This is the
   sharpest discriminator available and it costs nothing:
   - Internal keyboard responds (it is PS/2 on `isa0060/serio0`, independent of
     USB) but the **USB Logitech keyboard is dead** → **USB/xhci wedge**. The
     kernel is alive; only the USB stack (and therefore your input and possibly
     the dock's DP link) is gone.
   - **Neither** keyboard responds → deeper kernel/PM wedge, USB is not the story.
   Also try **unplugging the dock/USB-C** — if the laptop's own panel comes back,
   the failure is in the dock/USB4 path.
1. **`Ctrl+Alt+F2`** (internal keyboard) — does a text console appear? If yes, the
   kernel and input are fine and only the GPU/compositor is wedged.
2. **SSH in from your phone or another machine** (`ssh omarchy-tp` over tailscale,
   or its LAN IP). If SSH works, the kernel is fully alive → this is a
   **GPU/compositor wedge**, not a system freeze. Then capture:
   ```
   journalctl -k -n 200 > /tmp/freeze-dmesg.txt
   cat /proc/pressure/memory; free -m; swapon --show
   ps -eo pid,stat,wchan:24,comm --sort=-pcpu | head -20   # look for D-state tasks
   sudo dmesg | grep -iE 'i915|guc|gpu hang|reset|usb'
   ```
   Then `sudo systemctl restart <compositor unit>` or just reboot cleanly.
3. **`Alt+SysRq+h`** (needs `kernel.sysrq=1` from 1b) — if the help line reaches
   `dmesg`, the kernel is alive. Then **R E I S U B** reboots cleanly instead of a
   hard power-off.
4. Note whether you were **on AC or battery**, and what the **battery %** was.

**Any one of these answers is worth more than everything else in this document.**
If SSH works → GPU/i915. If nothing responds at all → deeper kernel/PM wedge.

**0c. MAKE THE NEXT FREEZE DIAGNOSABLE — highest-value item in the plan.** [repo][sys]

Every freeze so far produced zero evidence. Fix that *first*; it is cheap and it
is the only thing guaranteed to advance the diagnosis.

`syshardening/etc/sysctl.d/99-zz-hang-capture.conf`:
```
# Turn a silent wedge into a logged, recoverable event.
kernel.sysrq = 1                    # Alt+SysRq+f / REISUB (keyboard is PS/2, so SysRq survives a USB wedge)
kernel.hung_task_timeout_secs = 60  # report tasks blocked >60s
kernel.hung_task_panic = 1          # ...and panic, so pstore captures a stack instead of silence
kernel.panic = 20                   # auto-reboot 20s after panic
kernel.panic_on_oops = 1
```
Then confirm a persistent store exists so the panic survives the reboot:
```
ls /sys/fs/pstore/          # after a panic, the dmesg tail lands here
mount | grep pstore         # efi-pstore/ERST backend
```
If `/sys/fs/pstore` is unavailable, fall back to `netconsole` over the LAN or run
`journalctl -f` on a second machine over SSH during suspect periods.

> **Tradeoff, stated plainly:** `hung_task_panic=1` converts a 40-minute freeze
> into a fast automatic reboot. You lose unsaved work sooner — but you currently
> lose it anyway *and* learn nothing. Revert this once a stack trace is captured.

**0b. Decide from the numbers:**
- If a single LTO link peaks **> ~8 GB RSS** → native full builds of this tree
  **cannot fit** on a 16 GiB machine no matter how the cgroups are tuned. Route
  full builds to Docker (already capped at 12 G) or a bigger box, and treat
  `membuild` as protection for *incremental* builds only. **This is the likely
  outcome and it is the single most important thing to establish.**
- If peak zram RAM stays small and the disk swapfile is never touched → the zram
  resize (3a) is unnecessary; skip it.
- Use peak desktop-idle usage to size `membuild`'s `MemoryMax` (Phase 2d).

---

## Phase 1 — Break the livelock (safe, do first)

### 1a. Disk-backed swap — `omarchy-hibernation-setup`  [user][sys]

```
omarchy-hibernation-available          # Limine + /sys/power/image_size — both present
sudo omarchy-hibernation-setup         # interactive; reboot when it offers
```
Creates btrfs subvol `/swap` (dedicated, so **snapper does not snapshot it** —
required for a btrfs swapfile), `/swap/swapfile` sized to `MemTotal` (~16 GiB,
`chattr +C`), fstab entry `pri=0`, `resume` mkinitcpio hook, `resume=`/
`resume_offset=` Limine drop-in, rebuilds the UKI.

Verify after reboot — must show **both**:
```
swapon --show     # /dev/zram0 PRIO 100  AND  /swap/swapfile PRIO 0
```

> **Honest caveat:** this couples the stability fix to a hibernation feature you
> did not ask for — it adds a `resume` hook and kernel cmdline args, i.e. new boot
> surface on an already-unstable machine. The decoupled alternative is a plain
> swapfile with no resume wiring:
> ```
> sudo btrfs subvolume create /swap && sudo chattr +C /swap
> sudo btrfs filesystem mkswapfile -s 16g /swap/swapfile
> echo '/swap/swapfile none swap defaults,pri=0 0 0' | sudo tee -a /etc/fstab
> sudo swapon -a
> ```
> Both are fine. The official tool was chosen; if hibernation ever misbehaves,
> `sudo omarchy-hibernation-remove` reverts it and you can fall back to the above.

**This is the single highest-impact change in the plan** — it gives the kernel a
place to page that needs no RAM allocation, so reclaim can make forward progress
and, worst case, the OOM killer can finally engage instead of thrashing forever.

### 1a-bis. Stop the Goodix fingerprint reset loop  [repo][sys] — NEW in rev 3

Cheap, safe, independently correct, and it **removes a variable** from the
experiment. Disable USB autosuspend for just that device:

`syshardening/etc/udev/rules.d/50-goodix-no-autosuspend.rules`:
```
# Goodix 27c6:659a fingerprint reader resets continuously (~118/hour) because it
# fails to resume from USB autosuspend. Pin it powered-on.
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="27c6", ATTR{idProduct}=="659a", TEST=="power/control", ATTR{power/control}="on"
```
Apply without reboot:
```
sudo udevadm control --reload-rules
sudo udevadm trigger --action=add --subsystem-match=usb
cat /sys/bus/usb/devices/3-6/power/control     # expect: on
```
**Verify it worked** — after ~2 hours:
```
journalctl -k -b 0 --since "-2h" | grep -c 'usb 3-6:.*reset'   # expect 0 (baseline: ~118/hour)
```
If the loop persists with `control=on`, the reader is faulty rather than a
suspend-resume victim; the next step would be blacklisting it (and disabling
fingerprint unlock in `/etc/pam.d/omarchy-lock-fingerprint`) to test whether
freezes stop.

> This is worth doing **regardless** of whether it turns out to cause the
> freezes: 851 spurious device resets per boot is a defect on its own.

### 1b. Reclaim headroom + SysRq rescue  [repo][sys]

`syshardening/etc/sysctl.d/99-zz-hang-mitigation.conf` (sorts after Omarchy's
`99-omarchy-sysctl.conf`, so these win):
```
# Bigger kswapd reserve so background reclaim starts earlier (default here ~66 MB).
vm.min_free_kbytes = 262144
# Enable all magic-SysRq functions (currently 16 = sync only), so Alt+SysRq+f
# (OOM-kill) and REISUB can rescue a freeze without the power button.
kernel.sysrq = 1
```
Apply: `sudo sysctl --system`. **Keep** Omarchy's `vm.swappiness=150`,
`vm.watermark_scale_factor=125`, `vm.page-cluster=0`, dirty-bytes caps — already
correct for zram; do not duplicate or fight them.

*Both knobs are low-risk and reversible.* `kernel.sysrq=1` alone converts every
future hang from "hold the power button" into "Alt+SysRq+f".

### 1c. Document SysRq recovery  [repo]

In `AGENTS.md` + a `KEYBINDINGS.md` footnote: on the E14 the SysRq key is
`Alt`+`PrtSc`. During a freeze hold it and tap `f` (OOM-kill the biggest task —
usually enough), or **R E I S U B** to sync + remount-ro + reboot cleanly.
Requires 1b.

---

## Phase 2 — Contain builds

### 2a. Global parallelism caps  [repo]

Append to `bash-omarchy/.bashrc` (this package also ships to the Mac Air, hence
the guard — note the explicit readability test, not just an `awk` fallback):
```sh
# Cap parallel builds on low-memory hosts. Enforces the ~/.claude/CLAUDE.md rule
# (6 cores on this 16 GB laptop) that was previously documentation-only.
if [[ -r /proc/meminfo ]] &&
   (( $(awk '/MemTotal/{print int($2/1024/1024)}' /proc/meminfo) <= 20 )); then
  export MAKEFLAGS="-j6"
  export CMAKE_BUILD_PARALLEL_LEVEL=6
  export CTEST_PARALLEL_LEVEL=6
  export CARGO_BUILD_JOBS=6
  # NOTE: deliberately NOT exporting SQPL_COMPILE_CORES — see below.
fi
```

> **Deliberate omission.** Exporting `SQPL_COMPILE_CORES=6` would cap
> `platform` (24→6) and help a lot, **but it would *raise* pqr from its current
> effective `-j4` to `-j6`** — pqr has the heaviest translation units in the tree
> (15–17 MB `.o`). On a memory-bound box that is a regression. Either leave it
> unset (pqr keeps 4, platform is capped by `MAKEFLAGS`/`CMAKE_BUILD_PARALLEL_LEVEL`
> anyway) or set it per-project. Revisit with Phase 0 data.

### 2b. Conan 2 job cap  [repo]

New stow package `conan/` → `conan/.conan2/global.conf`:
```
tools.build:jobs=6
```
Caps both `cmake --build --preset` (currently `"jobs": 22`) and
`conan install --build=missing` (boost/folly/abseil on 22 cores — the single
heaviest scenario, and the one implicated in the boot -2 event). Add `conan` to
`OMARCHY_PKGS` + `MACAIR_PKGS` in `scripts/bootstrap.sh`; `stow -n -v conan` then
`stow conan`.

### 2c. makepkg / AUR cap  [repo][sys]

`syshardening/etc/makepkg.conf.d/10-local-jobs.conf`:
```
MAKEFLAGS="-j6"
```
Survives pacman updates (unlike editing `/etc/makepkg.conf`). Caps AUR rebuilds
during `omarchy-update`.

### 2d. `membuild` wrapper  [repo]

`omarchy-overrides/.config/bin/membuild` (`chmod 755`):
```sh
#!/usr/bin/env bash
# Run a build under a hard memory ceiling so a runaway compile/link is OOM-killed
# in its own cgroup instead of freezing the desktop.
#
# Sizing: total usable RAM is ~15.1 GiB and the idle desktop holds ~6-8 GiB, so
# the build must fit in roughly 6-7 GiB. Override per-invocation:
#   MEMBUILD_HIGH=4G MEMBUILD_MAX=6G membuild ninja
set -euo pipefail
exec systemd-run --user --scope --collect --slice=build.slice \
  --description="membuild: $*" \
  -p MemoryHigh="${MEMBUILD_HIGH:-5G}" \
  -p MemoryMax="${MEMBUILD_MAX:-7G}" \
  -p MemorySwapMax="${MEMBUILD_SWAP:-4G}" \
  -p CPUWeight=40 -p IOWeight=40 \
  -- "$@"
```
- `MemoryHigh=5G` → throttled by reclaim as it approaches; the build slows
  instead of the machine freezing.
- `MemoryMax=7G` → hard cap; the cgroup OOM killer takes `cc1plus`/`ld`, **not**
  Hyprland.
- **No `CPUQuota`.** CPU was never the failure mode, `-j6` already bounds
  concurrency, and a quota only adds scheduling latency. (rev 1 had `CPUQuota=600%`
  — dropped.)
- **These numbers replace rev 1's `MemoryHigh=8G`/`MemoryMax=10G`, which did not
  fit:** 10 G build + ~7 G desktop = 17 G on a 15.1 G machine, i.e. guaranteed
  swap pressure — the plan would have re-created the problem it fixes. Confirm the
  final numbers against Phase 0 measurements.

Usage: `membuild ./build.sh Release` · `membuild cmake --build --preset conan-debug`
· `membuild conan install . --build=missing --profile …`

### 2e. oomd coverage for the build slice  [repo]

`omarchy-overrides/.config/systemd/user/build.slice.d/oomd.conf`:
```
[Slice]
ManagedOOMMemoryPressure=kill
ManagedOOMMemoryPressureLimit=40%
```
Backstop to the hard `MemoryMax`. `systemctl --user daemon-reload`.

### 2f. Early-warning notifier  [repo]

`omarchy-overrides/.config/bin/psi-warn` + a user timer (every 15 s): if
`/proc/pressure/memory` `some avg10` exceeds ~25 for two consecutive samples,
`notify-send -u critical` with the top-3 RSS processes. Turns "the machine froze
with no warning" into "you have ~20 seconds to Ctrl-C the build." Cheap, no
system-level change, and useful independent of everything else.

### 2g. Steer heavy builds to Docker  [docs]

Build scripts live in other repos (no edits here). Document in `AGENTS.md`: full
/clean builds of elaeocarpus / platform / pqr go through `docker compose up -d`
→ `docker exec … ./build.sh Release`. Already capped: `cpus: 6`, `cpuset: "0-5"`,
`mem_limit: 12g`, `memswap_limit: 12g`, and the image bakes the 6-core ENV
quartet. **If Phase 0b shows LTO links exceed ~8 GB, this stops being a
preference and becomes the only workable native path.**

---

## Phase 3 — Judgement calls (drive these with Phase 0 data)

### 3a. zram resize — OPTIONAL, and the rationale in rev 1 was wrong

**Do not do this reflexively.** Measured on this machine: `DISKSIZE 15.1G, DATA
768.1M, COMPR 271M, TOTAL 284.4M`. `disksize` is a **lazily-allocated ceiling**,
not a reservation — **shrinking it frees zero RAM**, and it does not touch the
per-page `folio_alloc_swap` allocation that actually failed in boot -2.

The *one* defensible argument for shrinking it is **swap priority ordering**:
zram is pri=100 and the new swapfile pri=0, so the disk is only touched once zram
is **completely full**. With a 15.1 G ceiling you must fill ~15 G of zram — and
burn all the compression CPU to do it — before the disk safety valve engages at
all. A smaller zram reaches that spill point sooner, while RAM headroom remains.

Counter-argument: at 2.8:1, a large zram is a genuine memory multiplier, and
spilling to a LUKS-encrypted btrfs swapfile costs CPU and latency (Omarchy's own
config comments say exactly this).

**Decision rule from Phase 0:** if the instrumented build shows zram RAM usage
climbing past ~3–4 GB while `avail` collapses and the swapfile stays untouched,
shrink it. Otherwise leave it alone. If shrinking, prefer 75% before 50%:
`syshardening/etc/systemd/zram-generator.conf.d/99-local.conf`
```
[zram0]
zram-size = ram * 3 / 4
compression-algorithm = zstd
swap-priority = 100
```
Apply: `sudo systemctl restart systemd-zram-setup@zram0` (**turns swap off/on —
do it on an idle system**).

### 3b. MGLRU anti-thrash TTL — OPTIONAL, aggressive

`syshardening/etc/tmpfiles.d/lru_gen.conf`:
```
w! /sys/kernel/mm/lru_gen/min_ttl_ms - - - - 1000
```
`sudo systemd-tmpfiles --create`. Converts a silent multi-minute thrash into a
fast, logged OOM kill. **Understand the tradeoff:** it *causes OOM kills* that
would not otherwise happen. That is the point, but expect processes to die under
pressure that previously just made the machine slow. Start at `100`, not `1000`,
if you want a gentler first step. Revert by deleting the file.

### 3c. oomd reaction time — OPTIONAL, global side-effect

`syshardening/etc/systemd/oomd.conf.d/20-local.conf`:
```
[OOM]
DefaultMemoryPressureDurationSec=10s
```
Halves the sustained-stall window (was 20 s). **Caveat:** this is *global*, so it
also makes oomd more willing to kill things in `app.slice` — i.e. your browser or
terminal may get killed during heavy-but-survivable use. The per-slice limit in 2e
already covers builds specifically; consider skipping 3c unless Phase 0 shows
oomd reacting too slowly.

### 3d. voxtype memory  [repo]

`voxtype/.config/voxtype/config.toml`, `[whisper]`: `on_demand_loading = false`
→ `true`. Frees the ~2 GiB Whisper model between dictations; costs a one-time
~1–3 s load on the first dictation after an idle gap. Low risk, easily reverted.

---

## Phase 4 — Thermal + hardware

### 4a. Thermal management  [user]
`thermald` cannot run on Meteor Lake here. Either install **`throttled`** (AUR,
ThinkPad thermal/power-limit daemon) and `sudo systemctl enable --now throttled`,
or minimally `powerprofilesctl set balanced` for daily use and builds.

### 4b. Decode the BERT record  [user][sys] — do this EARLY, it's cheap
```
sudo pacman -S --needed acpica rasdaemon
sudo cp /sys/firmware/acpi/tables/BERT /tmp/BERT.bin && sudo iasl -d /tmp/BERT.bin && cat /tmp/BERT.dsl
sudo journalctl -k -b 0 | grep -i -A8 BERT
sudo ras-mc-ctl --errors
```
Distinguishes a benign "unexpected reset" marker from a repeated MCE/thermal/PMIC
fault. A positive result would redirect this entire plan, so run it before the
Phase 3 tuning.

### 4c. RAM upgradeability — the real fix  [user][sys]
```
sudo pacman -S --needed dmidecode
sudo dmidecode -t memory | grep -E 'Size|Locator|Form Factor|Type:|Rank'
```
E14 Gen 6 (Intel) has a SO-DIMM slot per Lenovo PSREF; soldered-vs-slot is
SKU-dependent. **32–40 GiB would make Phases 2 and 3 largely unnecessary.**
16 GiB is genuinely marginal for "full desktop + browser + large LTO C++ builds",
and if Phase 0b shows the LTO link needs >8 GB, more RAM is the *only* fix that
lets these build natively at all. Everything else here is a stopgap.

---

# PART 4 — VERIFICATION

**Phase 1 (after reboot):**
1. `swapon --show` → `/dev/zram0` PRIO 100 **and** `/swap/swapfile` PRIO 0.
2. `sysctl vm.min_free_kbytes kernel.sysrq` → `262144`, `1`.
3. Second reboot: swapfile still present (fstab persisted).
4. Sanity-test SysRq on a *scratch* moment: `Alt+SysRq+h` prints the help line to
   `dmesg` — proves the key path works before you need it in anger.

**Phase 2:**
5. New login shell: `echo "$MAKEFLAGS $CMAKE_BUILD_PARALLEL_LEVEL"` → `-j6 6`.
6. `conan config show tools.build:jobs` → `6`.
7. `membuild sh -c 'echo ok'` exits 0; during a build,
   `systemd-cgls --user | grep build.slice` shows the transient scope.
8. `systemctl --user show build.slice -p ManagedOOMMemoryPressure` → `kill`.

**End-to-end proof:**
9. Pane A: `watch -n1 'grep -E "^(some|full)" /proc/pressure/memory; free -m | head -2; zramctl'`
10. Pane B: `membuild ./build.sh Release` on **pqr**. Expected: `build.slice`
    `MemoryCurrent` plateaus near 5–7 G, memory PSI stays well below 50%, **the
    desktop stays responsive**. If it hits the ceiling, `cc1plus`/`ld` is
    OOM-killed and the build **fails with a clean error** — which is the designed
    outcome, not a regression. See Phase 0b: a clean failure here means the build
    needs Docker or more RAM.

**Synthetic (no build):**
11. `sudo pacman -S --needed stress-ng`
12. `membuild stress-ng --vm 4 --vm-bytes 3G --timeout 60s` → scope OOM-killed at
    `MemoryMax`; `journalctl -k` shows a cgroup OOM kill scoped to `build.slice`;
    desktop unaffected.

---

# PART 5 — ROLLBACK

- Each `/etc` file is a discrete drop-in: `sudo rm` it, then `sudo sysctl --system`
  / `sudo systemctl restart systemd-zram-setup@zram0` / `sudo systemctl restart
  systemd-oomd` / reboot as appropriate.
- `sudo omarchy-hibernation-remove` reverts Phase 1a.
- Repo changes revert with `git`.
- `syshardening/install.sh` must implement `--uninstall` removing exactly what it
  installed.

---

# PART 6A — HOW TO ACTUALLY SETTLE THIS (experiment order)

Because neither candidate is proven, execute as a **sequence of experiments**,
not a shotgun. Change one variable at a time and wait for a freeze or a clean
interval long enough to be meaningful (baseline: freezes on 2026-08-20, -23, -31
→ roughly weekly, so give each step ~2 weeks).

1. **0c (hang capture) + 1a-bis (Goodix udev) + 1b (`sysrq`) together.** All are
   safe, none change memory behaviour, and together they either stop the freezes
   (→ Candidate B confirmed) or produce a stack trace the next time one happens
   (→ definitive answer either way). **Start here.**
2. **1a (disk swapfile).** Safe, addresses Candidate A structurally, cannot make
   anything worse.
3. **Phase 2 (build caps + `membuild`).** Independently correct regardless of the
   root cause.
4. **Phase 3 knobs — only if Phase 0 data justifies them.** Do not apply these
   speculatively; they have real side-effects and would muddy the experiment.

If a freeze occurs after step 1 with a pstore stack trace, that trace supersedes
everything in this document.

# PART 6 — KNOWN GAPS / OUT OF SCOPE

- **LTO is the elephant.** All three C++ repos have `DEFINE_ENABLE_LTO ON` with
  plain BFD `ld`, no `mold`/`lld`, no ccache, no `CMAKE_JOB_POOL_LINK`. A
  full-program LTO link is a *single* process that can dwarf every parallel
  compiler combined. **No cgroup tuning makes an 8–16 GB link fit in 16 GB of
  RAM.** Phase 0b measures this; if confirmed, the fix is `mold` +
  `CMAKE_JOB_POOL_LINK=1` + `-g1` + LTO-off for dev builds — all of which live in
  the `quant-research` / `elaeocarpus` repos, not here.
- Desktop-baseline consumers (multiple `claude` sessions, Chromium) — the ~7 GB
  floor is itself half the machine. Not addressed.
- `btop` launcher/menu-icon issue reported separately — needs clarification on
  what "not working" means (`btop` 1.4.7 itself runs fine).
- The plan changes several kernel/systemd knobs at once. If anything regresses,
  bisect by removing `syshardening/etc` files one at a time. See Part 6A for the
  order that keeps the experiment interpretable.
- **Boot -7 (2026-08-20 18:23:43) is unexplained.** It froze while idle
  (last entries: routine `tailscaled` netcheck chatter, then ~2 min of silence),
  with no fingerprint reset loop and no memory-pressure event. If freezes continue
  after Phase 1, this boot is the shape to investigate — it fits neither candidate.
- **Boot -4's proximate trigger may be the monitors, not either candidate.** Its
  last lines are both BenQ GW3290QT USB HID devices attaching and then
  disconnecting 7 s before the freeze. BenQ USB churn is common in clean boots too
  (68–526 events), so this is not evidence on its own — but a dock/monitor
  hot-unplug wedging the machine is a third hypothesis worth keeping in mind, and
  it would be testable by noting whether future freezes coincide with
  plugging/unplugging the displays.
- The "builds trigger it" assumption is **not supported** by the retained logs
  (2 of 3 freezes were at idle). Worth the user consciously noting what they were
  doing at the next freeze.

---

# APPENDIX — RAW STATE AS INVESTIGATED (2026-08-31)

**Swap/zram:** `/dev/zram0` only — `DISKSIZE 15.1G, DATA 768.1M, COMPR 271M,
TOTAL 284.4M` (≈2.8:1; ceiling is lazily allocated). Priority 100. No disk swap,
no `resume=`. `/usr/lib/systemd/zram-generator.conf.d/90-omarchy.conf`:
`zram-size = ram`, `compression-algorithm = zstd`, `swap-priority = 100`.

**sysctl set by Omarchy** (`/etc/sysctl.d/99-omarchy-sysctl.conf`):
`vm.swappiness=150`, `vm.watermark_scale_factor=125`, `vm.watermark_boost_factor=0`,
`vm.vfs_cache_pressure=50`, `vm.page-cluster=0`, `vm.dirty_bytes=268435456`,
`vm.dirty_background_bytes=67108864`, `vm.dirty_writeback_centisecs=1500`.

**sysctl still at defaults** (Phase 1b/3b targets): `vm.min_free_kbytes≈67584`
(~66 MB) · `kernel.sysrq=16` · `kernel.hung_task_panic=0` ·
`kernel.softlockup_panic=0` · `lru_gen/min_ttl_ms=0` · THP `[always]` · zswap off
(correct for zram).

**OOM protection:** `systemd-oomd` active+enabled;
`/etc/systemd/oomd.conf.d/10-omarchy.conf` → `DefaultMemoryPressureLimit=50%`,
`DefaultMemoryPressureDurationSec=20s`; global `SwapUsedLimit=90%`. Only
`user@1000.service/app.slice` is a kill candidate
(`/usr/lib/systemd/user/app.slice.d/10-oomd.conf`); `session.slice` (Hyprland)
deliberately excluded. **No `MemoryHigh`/`MemoryMax` anywhere** on the user
hierarchy. `earlyoom`/`nohang`/`uresourced` not installed. oomd has never killed
anything.

**Builds:** no `MAKEFLAGS`/`CMAKE_BUILD_PARALLEL_LEVEL`/`SQPL_COMPILE_CORES`/
`CTEST_PARALLEL_LEVEL` exported anywhere (checked `~/.bashrc`, `/etc/environment`,
`/etc/profile.d`, mise) — the 6-core rule is doc-only.
`platform/research00/build.sh` line 3 `# source ./setup_ib.sh` disabled → bare
`ninja` = nproc+2 = **24 jobs**; `cmake/build_options.cmake:40` LTO ON; gold
linker gated on `NOT DEFINE_ENABLE_LTO` → plain BFD `ld`.
`pqr/reseachr00/build.sh` sources `setup_ib.sh` → `SQPL_COMPILE_CORES` unset →
**`-j4`** via a script-local alias (bypassed by direct `make`/`cmake --build`);
`Release/` = 6.1 GB, 657 `.o` (~1.5 GB), largest 17.6 MB; LTO on.
`elaeocarpus-x86` Conan preset `"jobs": 22` (build **and** test); `~/.conan2/
global.conf` has no `tools.build:jobs` → `conan install --build=missing` uses 22.
`/etc/makepkg.conf`: `#MAKEFLAGS="-j2"` commented; `OPTIONS=(... lto)`.
**Docker is capped**: `cpus: 6`, `cpuset: "0-5"`, `mem_limit: 12g`,
`memswap_limit: 12g` + image ENV `SQPL_COMPILE_CORES=6 CMAKE_BUILD_PARALLEL_LEVEL=6
CTEST_PARALLEL_LEVEL=6 MAKEFLAGS=-j6` — only via `docker compose`; `docker build`
and `platform/research00/Dockerfile` (`make -j$(nproc)`) are uncapped.

**Thermal:** `thermald` 2.5.12 installed + enabled but **inactive (dead)**
("Thermald can't run on this platform" / "Unsupported cpu model").
`throttled`/`tlp` not installed. `power-profiles-daemon` active, profile
`performance`; `platform_profile=performance`. Package ~80–82 °C at ~0.4 load,
fans ~3800 rpm.

**Forensics:** persistent journald (`/var/log/journal`, 3.1 GiB, 30 boots to
2026-06-29). `last -x` → ~30 boots `- crash`; `system.journal corrupted` ~30×
since April (2026-08-23, 08-21, 08-20, 08-09, 08-07, 08-06, 07-29 …). Exactly one
memory-pressure kernel event retained: boot -2, 2026-08-26 19:52:14. Boot -1 ends
2026-08-31 08:34:41 mid-idle-lock with no shutdown sequence. Boot 0:
`BERT: [Hardware Error] … Total records found: 1`. Coredumps: none tied to the
freezes; one `conan … conftest` SIGABRT at 2026-08-26 19:48:56.

**Goodix fingerprint reader (rev 3):** `usb 3-6` = `27c6:659a` "Goodix USB2.0
MISC", serial `UID3E599426_XXXX_MOC_B0`, `Driver=[none]` at kernel level (driven
from userspace by libfprint's `goodixmoc`). Enrolled and in use:
`fprintd-list` → "Goodix MOC Fingerprint Sensor (press)", `#0: right-index-finger`;
Omarchy lock uses PAM config `omarchy-lock-fingerprint`. Power state:
`power/control=auto`, `autosuspend_delay_ms=2000`, `runtime_status=suspended`,
`runtime_active_time≈5.9 h` of ~12.6 h uptime; global `usbcore.autosuspend=2`;
**no udev rule matching `27c6`** anywhere in `/etc/udev/rules.d` or
`/usr/lib/udev/rules.d`. Reset counts per boot: -1 **851**, -4 **469**, 0 (current)
**734 in ~13 h**; vs clean boots -3 **12** (over 2.7 days), -8 **4**, -6 **8**,
-5 **6**. Boot -7 (also abrupt): **0**. All resets target `3-6` exclusively.

**Input devices:** internal keyboard = `AT Translated Set 2 keyboard` on
`isa0060/serio0` (**PS/2 via i8042, not USB**), handlers include `sysrq`. Bus 3
USB carries only the Goodix reader, the Luxvisions camera, and the AX211
Bluetooth radio — no keyboard/touchpad. Therefore a wedged xhci does not directly
explain unresponsive input, and SysRq from the internal keyboard should survive a
USB-only failure.

**Boot classification (verified by presence/absence of a shutdown sequence, not
`last -x`):** abrupt = **-1** (2026-08-31 08:34:41), **-4** (2026-08-23 18:56:59),
**-7** (2026-08-20 18:23:43). Clean = -3, -5, -6, -8.

**Hibernation tooling present:** `omarchy-hibernation-{setup,available,remove}`;
Limine + `limine-mkinitcpio`; `/sys/power/image_size` present;
`/sys/power/mem_sleep = [s2idle]` only. **snapper + limine-snapper-sync installed,
`/.snapshots` exists** — the swapfile must live on its own subvolume (which
`omarchy-hibernation-setup` does).
