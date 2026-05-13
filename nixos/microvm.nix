{ config, pkgs, lib, ...}:
{
  users.users.kang.password = lib.mkDefault "";

  virtualisation.diskSizeAutoSupported = true;

  services.qemuGuest.enable = lib.mkDefault true;
  services.openssh.enable = true;
  services.lvm.enable = false;

  security.audit.enable = false;

  system.build.installBootLoader = lib.mkForce "${pkgs.coreutils}/bin/true";

  networking.useDHCP = lib.mkForce true;
  networking.dhcpcd.enable = true;
  networking.useNetworkd = lib.mkForce false;
  networking.firewall.enable = false;

  # from nixpkgs/nixos/modules/virtualisation/proxmox-lxc.nix
  systemd.services.register-nix-paths = {
    description = "Register Nix Store Paths";
    unitConfig = {
      DefaultDependencies = false;
      ConditionPathExists = "/nix-path-registration";
    };
    wantedBy = [ "sysinit.target" ];
    before = [
      "sysinit.target"
      "shutdown.target"
      "nix-daemon.socket"
      "nix-daemon.service"
    ];
    after = [ "local-fs.target" ];
    conflicts = [ "shutdown.target" ];
    restartIfChanged = false;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${lib.getExe' config.nix.package.out "nix-store"} --load-db < /nix-path-registration
      rm /nix-path-registration

      # nixos-rebuild also requires a "system" profile
      ${lib.getExe' config.nix.package.out "nix-env"} -p /nix/var/nix/profiles/system --set /run/current-system
    '';
  };

  systemd.services."serial-getty@ttyS0" = {
    enable = true;
    wantedBy = [ "getty.target" ];
    serviceConfig.Restart = "always";
  };

  boot.isContainer = lib.mkForce false;
  boot.initrd.enable = false;
  boot.loader.initScript.enable = true;
  boot.loader.grub.enable = false;
  boot.kernel.enable = false;

  console.enable = lib.mkDefault true;

  nix.optimise.automatic = lib.mkDefault false;
  powerManagement.enable = lib.mkDefault false;
  documentation.nixos.enable = lib.mkDefault false;

  systemd.services.qemu-guest-agent.enable = true;
}
