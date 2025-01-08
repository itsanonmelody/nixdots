{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./xkb/us-dpe
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
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva
        vaapiVdpau
      ];
    };
    opentabletdriver.enable = true;
    sane.enable = true;
    xpadneo.enable = true;
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
    libinput = {
      enable = true;
      mouse = {
        accelProfile = "flat";
      };
      touchpad = {
        accelProfile = "flat";
      };
    };
    passSecretService = {
      enable = true;
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
    tlp = {
      enable = true;
      settings = {
        CPU_DRIVER_OPMODE_ON_AC = "active";
        CPU_DRIVER_OPMODE_ON_BAT = "passive";

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
	
	RADEON_DPM_STATE_ON_AC = "performance";
	RADEON_DPM_STATE_ON_BAT = "battery";
	RUNTIME_PM_DRIVER_DENYLIST = "mei_me";
	
	START_CHARGE_THRESH_BAT1 = 85;
	STOP_CHARGE_THRESH_BAT1 = 90;
      };
    };
    udev = {
      extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      '';
    };
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    xserver.xkb = {
      layout = "de";
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
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    steam = {
      enable = true;
      dedicatedServer.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };
  users.defaultUserShell = pkgs.zsh;

  fonts = {
    packages = with pkgs;
      [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        (nerdfonts.override { fonts = [ "Noto" ]; })
      ];
    fontconfig.defaultFonts = {
      serif = [ "NotoSerif NF" "Noto Serif" ];
      sansSerif = [ "NotoSans NF" "Noto Sans" ];
      monospace = [ "NotoMono NF" ];
    };
  };

  system.copySystemConfiguration = true;
  system.stateVersion = "24.05";
}
