{ inputs, local, pkgs, ... }:
{
  imports = [
    inputs.hjem.nixosModules.default
    ./hardware-configuration.nix
    ./users.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        backgroundColor = "#000000";
        theme = "${local.pkgs.grubThemes.yorha-1080p}/grub/themes/yorha";
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
    plymouth = {
      enable = true;
      theme = "circle_hud";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [
            "circle_hud"
            "loader_2"
          ];
        })
      ];
    };
    initrd.verbose = false;

    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
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
    emacs = {
      enable = true;
      defaultEditor = true;
    };
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
      drivers = with pkgs; [
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
      theme = "sugar-dark";
      extraPackages = with pkgs.libsForQt5; [
        qt5.qtgraphicaleffects
        qt5.qtquickcontrols2
        qt5.qtsvg
      ];
    };
    xserver.xkb = {
      layout = "de";
    };
  };

  programs = {
    zsh.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
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

  environment.systemPackages = with pkgs; [
    sddm-sugar-dark
  ];

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      nerd-fonts.noto
    ];
    fontconfig.defaultFonts = {
      serif = [ "NotoSerif NF" "Noto Serif" ];
      sansSerif = [ "NotoSans NF" "Noto Sans" ];
      monospace = [ "NotoMono NF" ];
    };
  };

  hjem.clobberByDefault = true;

  system.stateVersion = "24.05";
}
