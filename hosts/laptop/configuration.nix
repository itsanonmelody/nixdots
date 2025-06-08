{ inputs, local, config, pkgs, lib, ... }:
{
  imports = [
    inputs.hjem.nixosModules.default
    ./hardware-configuration.nix
    ./users.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (final: prev: {
      emacs = pkgs.symlinkJoin {
        name = "emacsclient-only";
        paths = [ prev.emacs ];
        postBuild = ''
          rm $out/share/applications/emacs.desktop
          rm $out/share/applications/emacs-mail.desktop
        '';
      };
    })
  ];

  boot.extraModulePackages =
    let
      inherit (config.boot.kernelPackages) kernel;
      amdgpu-hang-fix = pkgs.fetchpatch {
        name = "amdgpu-hang-fix";
        url = "https://gitlab.freedesktop.org/agd5f/linux/-/commit/1b824eef269db44d068bbc0de74c94a8e8f9ce02.diff";
        hash = "sha256-LsmxcfL+ujHfTw+s7PMaRGYhuvCUWrc8vYhu6yMSzno=";
      };
      amdgpu-kernel-module =
        pkgs.stdenv.mkDerivation {
          pname = "amdgpu-kernel-module";
          inherit (kernel)
            src
            version
            postPatch
            nativeBuildInputs;

          kernel_dev = kernel.dev;
          kernelVersion = kernel.modDirVersion;

          modulePath = "drivers/gpu/drm/amd/amdgpu";

          buildPhase =
            ''
              BUILT_KERNEL=$kernel_dev/lib/modules/$kernelVersion/build

              cp $BUILT_KERNEL/Module.symvers .
              cp $BUILT_KERNEL/.config        .
              cp $kernel_dev/vmlinux          .

              make "-j$NIX_BUILD_CORES" modules_prepare
              make "-j$NIX_BUILD_CORES" M=$modulePath modules
            '';

          installPhase =
            ''
              make \
                INSTALL_MOD_PATH="$out" \
                XZ="xz -T$NIX_BUILD_CORES" \
                M="$modulePath" \
                modules_install
            '';

          meta = {
            description = "AMD GPU kernel module";
            license = lib.licenses.gpl3;
          };
        };
    in
      [
        (amdgpu-kernel-module.overrideAttrs {
          patches = [ amdgpu-hang-fix ];
        })
      ];

  boot = {
    loader = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
        configurationLimit = 5;
        backgroundColor = "#000000";
        splashImage = null;
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
      theme = "black_hud";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [
            "black_hud"
            "circle_hud"
            "hexagon_hud"
            "square_hud"
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
      "usbcore.autosuspend=-1"
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
      #dhcp = "dhcpcd";
      dns = "dnsmasq";
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
      enable = false;
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

        USB_AUTOSUSPEND = 0;
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
      package = pkgs.kdePackages.sddm;
      theme = "eucalyptus-drop";
      extraPackages = with pkgs.kdePackages; [
        qt5compat
        qtsvg
      ];
    };
    xserver.xkb = {
      layout = "de";
    };
  };

  programs = {
    zsh.enable = true;
    direnv.enable = true;
    hyprland = {
      enable = false;
      withUWSM = false;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    };
    gamemode.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    niri = {
      enable = true;
      package = pkgs.niri;
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-pipewire-audio-capture
      ];
    };
    steam = {
      enable = true;
      dedicatedServer.openFirewall = true;
      remotePlay.openFirewall = true;
    };
  };

  virtualisation.waydroid.enable = true;

  environment.systemPackages = builtins.concatLists [
    (with pkgs; [
      git
    ])
    (with local.pkgs; [
      (sddmThemes.eucalyptus-drop.overrideAttrs {
        postInstall =
          let
            wallpaperDir = "${inputs.self}/wallpaper/nier";
            wallpaperFile = "wp1987824.jpg";
          in
            ''
            chmod -R +w $out/share/sddm/themes/eucalyptus-drop
            cp ${wallpaperDir}/${wallpaperFile} $out/share/sddm/themes/eucalyptus-drop/Backgrounds/${wallpaperFile}
            sed -i \
              -e 's/Background=.*$/Background="Backgrounds\/${wallpaperFile}"/g' \
              -e 's/DimBackgroundImage=.*/DimBackgroundImage="0.2"/g' \
              -e 's/ScreenWidth=.*/ScreenWidth="1920"/g' \
              -e 's/ScreenHeight=.*/ScreenHeight="1080"/g' \
              -e 's/FullBlur=.*/FullBlur="true"/g' \
              -e 's/PartialBlur=.*/PartialBlur="true"/g' \
              -e 's/BlurRadius=.*/BlurRadius="10"/g' \
              -e 's/FormPosition=.*/FormPosition="center"/g' \
              -e 's/AccentColour=.*/AccentColour="#5f7240"/g' \
              -e 's/ForceHideCompletePassword=.*/ForceHideCompletePassword="true"/g' \
              -e 's/Locale=.*/Locale="de_DE"/g' \
              -e 's/DateFormat=.*/DateFormat="dddd, d MMMM yyyy"/g' \
              -e 's/HeaderText=.*/HeaderText="Willkommen!"/g' \
              $out/share/sddm/themes/eucalyptus-drop/theme.conf
        '';
      })
    ])
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
