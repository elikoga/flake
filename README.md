# elikoga nixos flake

## How to build a contabo bootstrab qcow2 image?

```shellcode
nix build .#nixosConfigurations.contaboBootstrap.config.system.build.qcow
```
