{ config, pkgs, ...}:

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
}
