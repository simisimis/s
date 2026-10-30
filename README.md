# My Nix repository

A nix flake for:
- NixOS configurations
- Home Manager configurations
- dev profile
- dev shell
- Templates

## Examples
### NixOS
```bash
$ sudo nixos-rebuild switch --flake git+ssh://git@github.com/simisimis/s#icarus
```

### Home Manager
```bash
$ home-manager switch --flake git+ssh://git@github.com/simisimis/s#icarus
```

### Home Manager on a non-NixOS machine (devops profile)
```bash
$ home-manager switch --flake git+ssh://git@github.com/simisimis/s#devops
```

### Dev shell
```bash
$ nix develop git+ssh://git@github.com/simisimis/s
```

### Language templates
```bash
$ nix flake init -t git+ssh://git@github.com/simisimis/s#rust
```

## Repository layout

Define hosts in `hosts/<name>/`. Add `configuration.nix` for a
`nixosConfigurations.<name>` output or `home.nix` for a
`homeConfigurations.<name>` output. In each host's `vars.nix`, set the host
identity, secrets, and `hw.role` (`headless` or `workstation`). Encrypt
`vars.nix` with git-crypt and follow `modules/vars-schema.nix`.

Layers, from general to specific:

- `nixos/base.nix`: shared NixOS settings (boot loader, ZFS import policy,
  OpenSSH, Tailscale, locale, user account, core CLI tools).
- `nixos/headless.nix`: servers; imports `nixos/initrd-unlock.nix` and
  `modules/k3s`, adds kube and admin CLI tools.
- `nixos/workstation.nix`: desktops; kernel selection, zfs maintenance, graphics,
  audio, fonts, portals, syncthing, sudo rules.
- `hm/base.nix`: shared home settings for shell, git identity, helix,
  jujutsu, gpg, fzf, and bat.
- `hm/headless.nix`: server homes; terminal pinentry only.
- `hm/workstation.nix`: desktop homes; Wayland desktop, apps, dev toolchains,
  wezterm, mako; imports `hm/devops.nix`.
- `hm/devops.nix`: kube, cloud and CLI toolset plus zellij, zoxide and kube
  shell helpers; used by workstation homes and the devops profile.
- `hosts/<name>/configuration.nix` and `hosts/<name>/home.nix`:
  machine-specific settings.

## devops profile

Use `profiles/devops/` for Home Manager on a non-NixOS Linux machine.
Import `hm/base.nix`, `hm/headless.nix`, and `hm/devops.nix`, and set
`targets.genericLinux.enable = true`. Encrypt the profile's `vars.nix` with
git-crypt, as you would for a host. This profile has no NixOS configuration.

```bash
$ home-manager switch --flake .#devops
```

## SSH keys

Add or rotate public SSH keys in `modules/keys.nix`, a plain attribute set.
Reference those keys in host `authorizedKeys` settings and use the initrd key
from the same file in `nixos/initrd-unlock.nix`.

## k3s and initrd unlock

For headless hosts, import `modules/k3s` through `nixos/headless.nix`.
Set `services.k3s.enable = true` to enable etcd, k3s server flags, Cilium
firewall openings, and `checkReversePath = false`. Use kouti and clotho as
enabled examples; on lachesis, leave k3s disabled to omit k3s and etcd settings.

Use `nixos/initrd-unlock.nix` to unlock ZFS over SSH from the initrd on port
2222, with the host key at `/etc/secrets/initrd/initrd-openssh-key`.
Import it through `nixos/headless.nix` for headless hosts or in the host
configuration for siMONSTER. Add the host's NIC driver to
`boot.initrd.kernelModules`.

## Rollback

To undo a NixOS switch, boot the previous generation from the systemd-boot
menu or run `nixos-rebuild switch --rollback`. You can choose from the last
five generations in the boot menu.

To undo a Home Manager switch, run `home-manager generations` and execute the
previous generation's `activate` script.
