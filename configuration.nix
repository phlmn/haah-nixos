{ pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGEEnbbN+qgKF36yjzq2TPBzyZUGtDJH4SYV4gmbDMT"
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    nodejs # for haah
  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;


  networking = {
    hostName = "haah";
    useDHCP = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "without-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    ipv4 = true;
    ipv6 = false;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      serial = {
        port = "/dev/ttyUSB0";
      };
      frontend = {
        port = 8080;
      };
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      8080 # zigbee2mqtt
      1883 # mqtt
      8883 # mqtt
      22
    ];
  };

  # do not write journal to disk to save sd card
  systemd.services.systemd-journal-flush.enable = false;

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  system.autoUpgrade.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

