# solo repo for nix and home-manager specific configuration. WIP

### bootstrap:
1. nixos:
```bash
$ sudo nixos-rebuild switch --flake git+ssh://git@github.com/simisimis/s
```
2. home-manager:
```bash
$ home-manager switch --flake git+ssh://git@github.com/simisimis/s
```

todo:
* proper readme
* add two more hosts
* come up with more refined structure
* finish this se...
