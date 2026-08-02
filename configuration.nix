# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.nix-minecraft.nixosModules.minecraft-servers
    ];

  nixpkgs.overlays = [ inputs.nix-minecraft.overlay ];

  # Bootloader.
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    useOSProber = true;
    efiSupport = true;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "mem_sleep_default=s2idle"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/tmp"
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = true;
    nvidiaSettings = true;
    
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.enableRedistributableFirmware = true;

  boot.kernelModules = [
    "mt7921u"
  ];

  services.udev.packages = [
      (pkgs.writeTextFile {
        name = "wifi_udev";
        text = ''
          SUBSYSTEM=="usb", ATTRS{idVendor}=="363e", ATTRS{idProduct}=="7961", RUN+="/bin/sh -c 'echo 363e 7961 > /sys/bus/usb/drivers/mt7921u/new_id'" 
	'';
        destination = "/etc/udev/rules.d/90-usb-363e:7961-mt7921u.rules";
      })
    ];

  security.polkit.enable = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      ubuntu-classic
      unifont
      nerd-fonts.jetbrains-mono
    ];

  fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Propo" ];
      };
    };
  };  


  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.flatpak.enable = true;
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.schuyler = {
    isNormalUser = true;
    description = "Schuyler";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
      neovim
      fastfetch
      vesktop
      obs-studio
      git
      kitty
      btop
      htop
      cmatrix
      spotify
      prismlauncher
    ];
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    policies.DisableTelemetry = true;
  };

  programs.steam = {
    enable = true;
  };

  programs.gpu-screen-recorder.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    wget
    papirus-icon-theme
    unzip
    gpu-screen-recorder-gtk
    pavucontrol
  ];

  services.minecraft-server = {
    enable = false;
    eula = true;
    openFirewall = true;

    serverProperties = {
      difficulty = "hard";
      motd = "hello to my minecaft server thank you";
    };

    jvmOpts = "-Xms4G -Xmx6G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5";

    package = pkgs.minecraft-server.overrideAttrs (oldAttrs: rec {
      version = "26.2"; # The specific release you are targeting
      url = "https://piston-data.mojang.com/v1/objects/823e2250d24b3ddac457a60c92a6a941943fcd6a/server.jar"; # Replace with official MOJANG URL
      sha256 = "1i9ynvmh1h46v310jmv08rz0cxrgfb1dqp8f9d5mxplqb2rdzb6d"; # Replace with the calculated SHA256
    }); 
  };

  services.minecraft-servers = {
    enable = false;
    eula = true;
    openFirewall = true;
    servers.neoforge = {
      enable = true;

      package = pkgs.neoforgeServers.neoforge-1_21_1;
      autoStart = false;
      serverProperties = {
        level-seed = -504904575;
	difficulty = "normal";
	spawn-protection = 0;
	motd = "create aeronautics";
      };

      symlinks = {
        mods = pkgs.linkFarmFromDrvs "mods" (
          builtins.attrValues {
            Create = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/LNytGWDc/versions/UjX6dr61/create-1.21.1-6.0.10.jar";
              sha512 = "11cc8fc049d2f67f6548c7abfada6b82a3adb5c7ca410a742de04bbca76e03862c518721b88d806f6e6d768a4d68531fdb903a85859b25d1484d550cc7bafd4b";
            };
            Create-Aeronautics = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/oWaK0Q19/versions/w7zlLnea/create-aeronautics-bundled-1.21.1-1.3.0.jar";
              sha512 = "2abba2e166a0ec8d42ab06108b63070d61f985420ecca8739c5b2300561b31486b69b3ad13310b0c459edb9edebeffb55a4cdf4ce493805833d32f5bde9ce778";
            };
	    Sable = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/T9PomCSv/versions/1L6XJqnY/sable-neoforge-1.21.1-2.0.3.jar";
	      sha512 = "c13c4da086001c205361905cd3a6c59a76e3c7d4c082265aaf3baf2fd30c79808f6634bca89aba29db5c096aa7da4066f76454093c306c3ae91c6c0d4d63ae0d";
	    };
            JEI = pkgs.fetchurl {
              url = "https://cdn.modrinth.com/data/u6dRKJwZ/versions/BTB3Mx37/jei-1.21.1-neoforge-19.27.0.344.jar";
	      sha512 = "7209d7b39d2867bd7bd2b90c4c1f085a327d9fe625ba25147f488de2516738d4b5d3abcccbb321476080c39b5b244e97d4de8bb456703afa7df3f59321a909b0";
	    };
          }
        );
      };
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
