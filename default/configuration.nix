# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  # Use the GRUB 2 boot loader.
  boot.loader.systemd-boot.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;




  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };
  users.users.minion = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNCOdHSYGKQj8QMQKuWsnTUCGpKNwQa+/15JVD7kxO4VxI0mavpoB6EIwVF881s2DYqRNv2UQIKbw/tZ8qnTbk8HvzvHBjuJE9okAfelphkiH60mM+FzRZrUaDFLKzTBy1fBAk1O35vNaXJS3qDdr2wQOU9D10Ulvq1RBRSVe4uWbZJUWbac/zq2ghRfcHEavhGVIqI7JRcBy8P721bFULs5lxEUMZM2MBavg2wvbFc41CXZSAmK3M+wS2WPdSA8GxbiMgcPhiArRfqJbO/v3NUGIHQnTRK3kEpblVLz9ULpTo0Kl4pcTgIGI0S3zSJIV2VXERnzkjEgNn8gjDVBCZEXyFlGlPNV1DBd+NZwcqfAXsUHGkOs+GPGm93QVsbPoqZ49N5BJg1SZCE7KWfQAnkWE/ki7Z7+BJAWbZsoc7KSz7bvy5jr6yfIzwmy4mAgiVZFfCDRI3S3oEbhqW8TWZatEPSjMgDLsh3AgYdzjYQ1p6IM91wvD+XxB0/8+LaL0= minion@python"
    ];
  };
  users.users.coded = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZGErwcw5YUlJS9tAfIYOSqkiuDRZZRTJjMlrDaAiNwTjqUML/Lrcau/1KA6a0+sXCM8DhQ1e0qhh2Qxmh/kxZWO6XMVK2EB7ELPNojqFI16T8Bbhq2t7yVAqbPUhXLQ4xKGvWMCPWOCo/dY72P9yu7kkMV0kTW3nq25+8nvqIvvuQOlOUx1uyR7qEfO706O86wjVTIuwfZKyzMDIC909vyg0xS+SfFlD7MkBuGzevQnOAV3U6tyafg6XW4PaJuDLyGXwpKz6asY08F7gRL/7/GhlMB09nfFfT4sZggmqPdGAtxwsFuwHPjNSlktHz5nlHtpS0LjefR9mWiGIhw5Hw1z33lxP0rfmiEU9J7kFcXv9B8QAWFwWfNEZfeqB7h7DJruo+QRStGeDz4SwRG3GR+DB4iNJLt7n0ALkVFJpOpskeo8TV4+Fwok+hYs2GsvdEmh9Cj7dC/9CyRhJeam9iLIi/iVGZhXEE3tIiqEktZPjiK7JwQyr97zhGJ7Rj4oE= samue@SamuelDesktop"
    ];
  };
  users.users.pinea = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICbuu0UvM5ouI70uX5zHoBP8sZElgsu/QTQizDqQsTxIAAAABHNzaDo= pineapplefan@Pineapplefan"
    ];
  };
  users.users.nucleus = {
    isSystemUser = true;
    createHome = true;
    home = "/services/nucleus";
    group = "clicks";
    shell = pkgs.bashInteractive;
  };
  users.users.websites = {
    isSystemUser = true;
    createHome = true;
    home = "/services/websites";
    group = "clicks";
    shell = pkgs.bashInteractive;
  };
  users.groups.clicks = { };

  programs.zsh.enable = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.hostName = "Clicks";
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  /* system.copySystemConfiguration = true; */

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
