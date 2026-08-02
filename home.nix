{ config, pkgs, inputs, ...}:

{
  home.username = "schuyler";
  home.homeDirectory = "/home/schuyler";
  home.stateVersion = "25.11";

  programs.bash = {
    enable = true;
    shellAliases = {
      btw = "echo i use hyprland btw";
    };
  };

  programs.mpv = {
    enable = true;
    config = {
      fullscreen = true;
      keep-open = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
	"video/*" = "mpv.desktop";
      };
  };


  programs.caelestia = {
    enable = true;
    systemd = {
      enable = false; # if you prefer starting from your compositor
      target = "graphical-session.target";
      environment = [ "QS_ICON_THEME=Papirus" ];
    };
    settings = {
      launcher.showOnHover = true;

      services.useFahrenheit = false;
      background.visualiser.enabled = true;

      bar.workspaces.activeTrail = true;

      utilities.toasts.kbLayoutChanged = false;

      osd = {
	enableBrightness = false;
	enableMicrophone = true;
      };

      bar.status = {
        showBluetooth = false;
	showAudio = true;
      };
    };
    cli = {
      enable = true; # Also add caelestia-cli to path
    };
  };
}
