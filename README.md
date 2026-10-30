# My nix Repository

A nix flake for:
- NixOS configurations
- Home Manager configurations
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

### Dev shell
```bash
$ nix develop git+ssh://git@github.com/simisimis/s
```

### Language templates
```bash
$ nix flake init -t git+ssh://git@github.com/simisimis/s#rust
```
