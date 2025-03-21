# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, lib, inputs, additionalPackages, isDesktop, ... }:

{
  imports = [
    ../common
    ./home-manager.nix
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Network NameServers
  networking.nameservers = [
    "192.168.219.150"
    "1.1.1.1"
  ];

  # Set your time zone.
  time.timeZone = "Asia/Seoul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ko_KR.UTF-8";
    LC_IDENTIFICATION = "ko_KR.UTF-8";
    LC_MEASUREMENT = "ko_KR.UTF-8";
    LC_MONETARY = "ko_KR.UTF-8";
    LC_NAME = "ko_KR.UTF-8";
    LC_NUMERIC = "ko_KR.UTF-8";
    LC_PAPER = "ko_KR.UTF-8";
    LC_TELEPHONE = "ko_KR.UTF-8";
    LC_TIME = "ko_KR.UTF-8";
  };
  i18n.inputMethod = {
    enabled = "kime";
  };

  services.logrotate.checkConfig = false;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "kr";
    variant = "kr104";
    options = "ctrl:swapcaps";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kang = {
    isNormalUser = true;
    description = "kang";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "docker" "wireshark" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = (with pkgs; [
    # vnc client
    wayvnc

    # fileSystem
    cifs-utils

    # cryptography disk
    cryptsetup

    # wireshark
    wireshark
  ]) ++ (import ../common/packages_desktop.nix { inherit pkgs inputs lib additionalPackages isDesktop; });

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  programs.sway = {
    extraPackages = with pkgs; [
      bemenu
      pcmanfm
      wayland
      swaylock
      swayidle
      mako
      wdisplays
      xdg-utils
    ];
    enable = isDesktop;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      font-awesome
      nanum
      nanum-gothic-coding
    ];

    fontconfig.defaultFonts = {
      serif = [ "NanumMyeongjo" "Noto Serif" ];
      sansSerif = [ "NanumGothic" "Noto Sans" ];
    };
  };

  programs.zsh.enable = true;

  programs.wireshark.enable = isDesktop;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # podman
  virtualisation.podman = {
    enable = isDesktop;
    dockerCompat = true;
  };
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
