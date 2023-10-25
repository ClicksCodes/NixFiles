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
  time.timeZone = "Etc/UTC";

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
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIteIdlZv52nUDxW2SUsoJ2NZi/w9j1NZwuHanQ/o/DuAAAAHnNzaDpjb2xsYWJvcmFfeXViaWtleV9yZXNpZGVudA== collabora_yubikey_resident"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJRzQbQjXFpHKtt8lpNKmoNx57+EJ/z3wnKOn3/LjM6cAAAAFXNzaDppeXViaWtleV9yZXNpZGVudA== iyubikey_resident"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOhzJ0p9bFRSURUjV05rrt5jCbxPXke7juNbEC9ZJXS/AAAAGXNzaDp0aW55X3l1YmlrZXlfcmVzaWRlbnQ= tiny_yubikey_resident"
    ];
  };
  users.users.coded = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZGErwcw5YUlJS9tAfIYOSqkiuDRZZRTJjMlrDaAiNwTjqUML/Lrcau/1KA6a0+sXCM8DhQ1e0qhh2Qxmh/kxZWO6XMVK2EB7ELPNojqFI16T8Bbhq2t7yVAqbPUhXLQ4xKGvWMCPWOCo/dY72P9yu7kkMV0kTW3nq25+8nvqIvvuQOlOUx1uyR7qEfO706O86wjVTIuwfZKyzMDIC909vyg0xS+SfFlD7MkBuGzevQnOAV3U6tyafg6XW4PaJuDLyGXwpKz6asY08F7gRL/7/GhlMB09nfFfT4sZggmqPdGAtxwsFuwHPjNSlktHz5nlHtpS0LjefR9mWiGIhw5Hw1z33lxP0rfmiEU9J7kFcXv9B8QAWFwWfNEZfeqB7h7DJruo+QRStGeDz4SwRG3GR+DB4iNJLt7n0ALkVFJpOpskeo8TV4+Fwok+hYs2GsvdEmh9Cj7dC/9CyRhJeam9iLIi/iVGZhXEE3tIiqEktZPjiK7JwQyr97zhGJ7Rj4oE= samue@SamuelDesktop"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+TJRuMpDPgh6Wp2h+E+O/WoyEAVyWo6SN8oxm2JZNVAAAABHNzaDo= samue@SamuelDesktop"
    ];
  };
  users.users.pineafan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFXa8ow7H8XpTrwYI+oSgLFfb6YNZanwv/QCKvEKiERSAAAABHNzaDo= pineapplefan@Pineapplefan"
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAJNFMUYiEepGrIAbUM+Hlw/OuGWc8CNQsYlJ7519RVmeu+/vqEQbhchySTelibD19YqsZ7ICfYxAeQzOqHdXfs="
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

  nix.settings.trusted-users = [ "minion" ]; # please do not add all wheel, only
  # add users when there is a specific need

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts =
    [ 80 443 25 465 587 110 995 143 993 29418 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;
  networking.hostName = "Clicks";
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
