{ lib, config, pkgs, modulesPath, inputs, ... }:
{
  # for virtio kernel drivers
  imports = [
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  boot.growPartition = true;
  boot.kernelParams = [ "console=ttyS0" ];
  boot.loader.grub.device = lib.mkDefault "/dev/vda";

  boot.loader.grub.efiSupport = lib.mkDefault true;
  boot.loader.grub.efiInstallAsRemovable = lib.mkDefault true;
  boot.loader.timeout = 0;

  system.build.qcow = import "${toString modulesPath}/../lib/make-disk-image.nix" {
    inherit lib config pkgs;
    format = "qcow2";
    partitionTableType = "hybrid";
    name = "contabo-nixos-disk-image-${lib.substring 0 8 (inputs.self.lastModifiedDate or inputs.self.lastModified or "19700101")}-${inputs.self.shortRev or "dirty"}";
  };
}

