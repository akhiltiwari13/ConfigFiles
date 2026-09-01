# memory for this system

## brief

> I am running this dev setup on omarchy linux distro (arch linux based) running on a fairly low powered m/c ie a thinkpad e14, with intel's ultra core processors.

> [!NOTE]
> compiling with all my cores used always freezes my system, therfore allways limit all compilation jobs to 6 virtual cores.

## worktree location policy (ALL repos, ALL harnesses)

> Every git worktree for a repo under `~/Work` lives at:
>
> ```text
> ~/Work/worktrees/<local-repo-dir>/<branch with "/" replaced by "-">
> ```
>
> Create lanes with `wt add <branch>` (computes the path) or
> `git worktree add -b <branch> ~/Work/worktrees/<repo>/<lane>`.
> Never nest a worktree inside its repo and never put one in /tmp.

> [!IMPORTANT]
> This is **enforced, not advisory**. `~/.config/bin/git` is a pass-through shim
> that refuses off-policy `git worktree add`, and a global `core.hooksPath`
> post-checkout hook reports anything that bypasses it. Do not try to work around
> them — if a repo genuinely needs an exception, add a glob to
> `~/.config/worktree-policy.conf`, or for a deliberate one-off use
> `WT_POLICY_BYPASS=1`.

> `wt-audit` lists every worktree across all repos and flags violations.
> `gwq list -g` is the cross-repo dashboard; `gwq cd` is an fzf jump that works in
> herdr, tmux and a bare terminal.

> The **only** standing exemption is quant-research, below: its worktrees are
> pinned inside `./pqr` and `./platform` because `docker-compose.yml` mounts those
> directories, and `pqr/platform` is a symlink to the container-absolute
> `/quant-research/platform/research00`. Moving them breaks the build.

## quant-research worktrees

> For the current quant-research work, use these branch-matched worktrees:

```text
PQR/platform_qr worktree: /home/quomptrade/Work/learn/quant-research/pqr/reseachr00
PQR branch: feature/research00

Platform/platform_v3 worktree: /home/quomptrade/Work/learn/quant-research/platform/research00
Platform branch: feature/research00

Docker/build environment root: /home/quomptrade/Work/learn/quant-research
Dockerfile: /home/quomptrade/Work/learn/quant-research/Dockerfile
docker-compose: /home/quomptrade/Work/learn/quant-research/docker-compose.yml
```

> Use the `platform/research00` worktree as the platform source base for the
> current PQR branch. PQR CMake resolves platform source as `../platform` when
> `BUILD_WITH_PLATFORM_SRC=ON`, so verify that path/layout points to the
> intended branch-matched platform source before full builds.

## current machine limits

> Current non-interactive probes show Arch Linux/Omarchy on host `omarchy-tp`,
> kernel `7.0.10-arch1-1`, Intel Core Ultra 7 155H, `22` logical CPUs, about
> `15 GiB` RAM, `4 GiB` swap, and `/home` on a `475G` btrfs filesystem. Docker
> reports `22` CPUs and `15.09GiB` RAM unless constrained. `btop` is installed
> (`1.4.7`) for interactive monitoring.

> Hard rule for this laptop: never compile with all cores. Limit every native
> and Docker build/run to max 6 CPUs/jobs using `SQPL_COMPILE_CORES=6`,
> `CMAKE_BUILD_PARALLEL_LEVEL=6`, `CTEST_PARALLEL_LEVEL=6`, `MAKEFLAGS=-j6`,
> `make -j6`, `ninja -j6`, Docker `--cpus=6`, or compose `cpus: 6` plus
> `cpuset: "0-5"` as appropriate. The quant-research compose config uses both
> `cpus: 6` and `cpuset: "0-5"` so container `nproc` reports 6.

## command log preference

> When running builds, tests, searches, or diagnostics for quant-research work,
> prefer visible command output over quiet/suppressed modes. Use plain/verbose
> build output when practical, for example Docker `--progress=plain`, CTest
> `--output-on-failure`, and direct command output. Tooling may still truncate
> very large logs, but do not intentionally hide build/search logs unless asked.

## memory information

> below is a snapshot of few linux commands executed on this system with daily workflow on!

```bash
mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ lscpu
Architecture:                x86_64
  CPU op-mode(s):            32-bit, 64-bit
  Address sizes:             46 bits physical, 48 bits virtual
  Byte Order:                Little Endian
CPU(s):                      22
  On-line CPU(s) list:       0-21
Vendor ID:                   GenuineIntel
  Model name:                Intel(R) Core(TM) Ultra 7 155H
    CPU family:              6
    Model:                   170
    Thread(s) per core:      2
    Core(s) per socket:      16
    Socket(s):               1
    Stepping:                4
    Microcode version:       0x28
    CPU(s) scaling MHz:      37%
    CPU max MHz:             4800.0000
    CPU min MHz:             400.0000
    BogoMIPS:                5990.40
    Flags:                   fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc art arch_perfmon pebs bts rep_good nopl
                              xtopology nonstop_tsc cpuid aperfmperf tsc_known_freq pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 sdbg fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xs
                             ave avx f16c rdrand lahf_lm abm 3dnowprefetch cpuid_fault epb ssbd ibrs ibpb stibp ibrs_enhanced tpr_shadow flexpriority ept vpid ept_ad fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid rdseed adx
                             smap clflushopt clwb intel_pt sha_ni xsaveopt xsavec xgetbv1 xsaves split_lock_detect user_shstk avx_vnni dtherm ida arat pln pts hwp hwp_notify hwp_act_window hwp_epp hwp_pkg_req hfi vnmi umip pku osp
                             ke waitpkg gfni vaes vpclmulqdq rdpid bus_lock_detect movdiri movdir64b fsrm md_clear serialize arch_lbr ibt flush_l1d arch_capabilities
Virtualization features:
  Virtualization:            VT-x
Caches (sum of all):
  L1d:                       544 KiB (14 instances)
  L1i:                       896 KiB (14 instances)
  L2:                        18 MiB (9 instances)
  L3:                        24 MiB (1 instance)
NUMA:
  NUMA node(s):              1
  NUMA node0 CPU(s):         0-21
Vulnerabilities:
  Gather data sampling:      Not affected
  Ghostwrite:                Not affected
  Indirect target selection: Not affected
  Itlb multihit:             Not affected
  L1tf:                      Not affected
  Mds:                       Not affected
  Meltdown:                  Not affected
  Mmio stale data:           Not affected
  Old microcode:             Not affected
  Reg file data sampling:    Not affected
  Retbleed:                  Not affected
  Spec rstack overflow:      Not affected
  Spec store bypass:         Mitigation; Speculative Store Bypass disabled via prctl
  Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
  Spectre v2:                Mitigation; Enhanced / Automatic IBRS; IBPB conditional; PBRSB-eIBRS Not affected; BHI BHI_DIS_S
  Srbds:                     Not affected
  Tsa:                       Not affected
  Tsx async abort:           Not affected
  Vmscape:                   Mitigation; IBPB before exit to userspace

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ nproc
22

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi        13Gi       189Mi       1.6Gi       3.8Gi       2.0Gi
Swap:          4.0Gi       4.0Gi       348Ki

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ free -h
               total        used        free      shared  buff/cache   available
Mem:            15Gi        13Gi       216Mi       1.6Gi       3.7Gi       2.0Gi
Swap:          4.0Gi       4.0Gi       172Ki

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ lspci | grep -Ei 'vga|3d|display'
00:02.0 VGA compatible controller: Intel Corporation Meteor Lake-P [Intel Graphics] (rev 08)

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ lsb_release -a
LSB Version: n/a
Distributor ID: Arch
Description: Arch Linux
Release: rolling
Codename: n/a

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ cat /etc/os-release
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ uname -a
Linux omarchy-tp 7.0.9-arch2-1 #1 SMP PREEMPT_DYNAMIC Fri, 22 May 2026 19:25:09 +0000 x86_64 GNU/Linux

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3
❯ inxi -Fxz
System:
  Kernel: 7.0.9-arch2-1 arch: x86_64 bits: 64 compiler: gcc v: 16.1.1
  Desktop: Hyprland v: 0.55.2 Distro: Arch Linux
Machine:
  Type: Laptop System: LENOVO product: 21M70098IG v: ThinkPad E14 Gen 6
    serial: <superuser required>
  Mobo: LENOVO model: 21M70098IG serial: <superuser required> Firmware: UEFI
    vendor: LENOVO v: R2JET44W(1.21 ) date: 10/28/2025
Battery:
  ID-1: BAT0 charge: 46.3 Wh (100%) condition: 46.3/47 Wh (98.6%) volts: 12.94
    min: 11.31 model: SMP L22M3PG4 status: full
CPU:
  Info: 16-core (6-mt/10-st) model: Intel Core Ultra 7 155H bits: 64
    type: MST AMCP arch: Meteor Lake rev: 4 cache: L1: 1.6 MiB L2: 18 MiB
    L3: 24 MiB
  Speed (MHz): avg: 2001 min/max: 400/4500:4800:3800:2500 cores: 1: 2001
    2: 2001 3: 2001 4: 2001 5: 2001 6: 2001 7: 2001 8: 2001 9: 2001 10: 2001
    11: 2001 12: 2001 13: 2001 14: 2001 15: 2001 16: 2001 17: 2001 18: 2001
    19: 2001 20: 2001 21: 2001 22: 2001 bogomips: 131788
  Flags-basic: avx avx2 ht lm nx pae sse sse2 sse3 sse4_1 sse4_2 ssse3 vmx
Graphics:
  Device-1: Intel Meteor Lake-P [Intel Graphics] vendor: Lenovo driver: i915
    v: kernel arch: Xe-LPG bus-ID: 00:02.0
  Device-2: Luxvisions Innotech Integrated Camera driver: uvcvideo type: USB
    bus-ID: 3-7:7
  Display: wayland server: X.org v: 1.21.1.22 with: Xwayland v: 24.1.11
    compositor: Hyprland v: 0.55.2 driver: X: loaded: modesetting dri: iris
    gpu: i915 resolution: 1: 2560x1440~75Hz 2: 2560x1440~75Hz
    3: 1920x1200~60Hz
  API: EGL Message: EGL data requires eglinfo. Check --recommends.
  Info: Tools: x11: xprop,xrandr
Audio:
  Device-1: Intel Meteor Lake-P HD Audio vendor: Lenovo
    driver: sof-audio-pci-intel-mtl bus-ID: 00:1f.3
  Device-2: Realtek BenQ GW3290QT driver: hid-generic,snd-usb-audio,usbhid
    type: USB bus-ID: 3-1.4:101
  Device-3: Realtek BenQ GW3290QT driver: hid-generic,snd-usb-audio,usbhid
    type: USB bus-ID: 3-9.4:100
  API: ALSA v: k7.0.9-arch2-1 status: kernel-api
  Server-1: sndiod v: N/A status: off
  Server-2: PipeWire v: 1.6.5 status: active
Network:
  Device-1: Intel Meteor Lake PCH CNVi WiFi driver: iwlwifi v: kernel
    bus-ID: 00:14.3
  IF: wlan0 state: up mac: <filter>
  Device-2: Intel Ethernet I219-LM vendor: Lenovo driver: e1000e v: kernel
    port: N/A bus-ID: 00:1f.6
  IF: enp0s31f6 state: down mac: <filter>
  IF-ID-1: br-1c62d9165423 state: down mac: <filter>
  IF-ID-2: br-661a687c4a61 state: down mac: <filter>
  IF-ID-3: docker0 state: up speed: 10000 Mbps duplex: unknown mac: <filter>
  IF-ID-4: tailscale0 state: unknown speed: -1 duplex: full mac: N/A
  IF-ID-5: veth8bc269b state: up speed: 10000 Mbps duplex: full
    mac: <filter>
  IF-ID-6: vetheef5eaa state: up speed: 10000 Mbps duplex: full
    mac: <filter>
Bluetooth:
  Device-1: Intel AX211 Bluetooth driver: btusb v: 0.8 type: USB
    bus-ID: 3-10:9
  Report: rfkill ID: hci0 rfk-id: 1 state: up address: see --recommends
Drives:
  Local Storage: total: 476.94 GiB used: 212.64 GiB (44.6%)
  ID-1: /dev/nvme0n1 vendor: Lenovo model: UMIS RPJTJ512MKP1QDQ
    size: 476.94 GiB temp: 54.9 C
Partition:
  ID-1: / size: 474.92 GiB used: 212.52 GiB (44.7%) fs: btrfs dev: /dev/dm-0
    mapped: root
  ID-2: /boot size: 2 GiB used: 115.9 MiB (5.7%) fs: vfat
    dev: /dev/nvme0n1p1
  ID-3: /home size: 474.92 GiB used: 212.52 GiB (44.7%) fs: btrfs
    dev: /dev/dm-0 mapped: root
  ID-4: /var/log size: 474.92 GiB used: 212.52 GiB (44.7%) fs: btrfs
    dev: /dev/dm-0 mapped: root
Swap:
  ID-1: swap-1 type: zram size: 4 GiB used: 4 GiB (100.0%) dev: /dev/zram0
Sensors:
  System Temperatures: cpu: 73.0 C mobo: N/A
  Fan Speeds (rpm): fan-1: 3800 fan-2: 3800
Info:
  Memory: total: 16 GiB note: est. available: 15.09 GiB
    used: 13.18 GiB (87.3%)
  Processes: 603 Uptime: 10d 10h 31m Init: systemd
  Packages: 1699 Compilers: clang: 22.1.5 gcc: 16.1.1 Shell: Bash v: 5.3.9
    inxi: 3.3.40

mmp-cexbot on  dev_kraken_mexc [$!?⇣] via △ v4.3.3 took 5s
❯
```
