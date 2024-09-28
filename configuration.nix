{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./users.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        backgroundColor = "#000000";
        extraEntries = ''
          if [ $grub_platform == "efi" ]; then
            menuentry "UEFI Firmware Settings" --id "uefi-firmware" {
              fwsetup
            }
          fi

          menuentry "Restart" {
            echo "Restarting system..."
            reboot
          }

          menuentry "Shutdown" {
            echo "Shutting down system..."
            halt
          }
        '';
     };
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    opentabletdriver.enable = true;
    sane.enable = true;
  };

  powerManagement.enable = true;

  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "de_DE.UTF-8";
    supportedLocales = [
      "de_DE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
    ];
  };

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  networking = {
    hostName = "femboyhooters";
    nameservers = [
      "1.1.1.2#security.cloudflare-dns.com"
      "2606:4700:4700::1112#security.cloudflare-dns.com"
    ];

    firewall.enable = true;
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };
  
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
      openFirewall = true;
    };
    blueman.enable = true;
    dbus.packages = with pkgs;
      [
        pass-secret-service
      ];
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
      touchpad = {
        accelProfile = "flat";
      };
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
      pulse.enable = true;
    };
    printing = {
      enable = true;
      drivers = with pkgs;
        [
          hplip
        ];
    };
    resolved = {
      enable = true;
      dnsovertls = "true";
      dnssec = "true";
      domains = [ "~." ];
      fallbackDns = [
        "1.0.0.2#security.cloudflare-dns.com"
        "2606:4700:4700::1002#security.cloudflare-dns.com"
      ];
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs;
    [
      helix
      nil      # language server for Nix language
    ];
  environment.variables = {
    "EDITOR" = "hx";
  };

  programs = {
    zsh.enable = true;
    hyprland.enable = true;
    gamemode.enable = true;
    steam = {
      enable = true;
      dedicatedServer.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };
  users.defaultUserShell = pkgs.zsh;

  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "Noto" ]; })
    ];

  system.copySystemConfiguration = true;
  system.stateVersion = "24.05";
}
