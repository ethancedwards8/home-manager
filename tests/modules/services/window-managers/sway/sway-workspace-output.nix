{ config, lib, pkgs, ... }:

with lib;

let

  dummy-package = pkgs.runCommandLocal "dummy-package" { } "mkdir $out";

in {
  config = let
    i3 = {
      ws1 = "1";
      ws2 = "ABC";
      ws3 = "3: Test";
      ws4 = ''!"§$%&/(){}[]=?\*#<>-_.:,;²³'';
    };

  in {
    wayland.windowManager.sway = {
      enable = true;
      package = dummy-package // { outPath = "@sway"; };
      # overriding findutils causes issues
      config.menu = "${pkgs.dmenu}/bin/dmenu_run";

      config.workspaceOutputAssign = [
        {
          workspace = "${i3.ws1}";
          output = "eDP";
        }
        {
          workspace = "${i3.ws2}";
          output = "DP";
        }
        {
          workspace = "${i3.ws3}";
          output = "HDMI";
        }
        {
          workspace = "${i3.ws4}";
          output = "DVI";
        }
      ];
    };

    nixpkgs.overlays = [ (import ./sway-overlay.nix) ];

    nmt.script = ''
      assertFileExists home-files/.config/sway/config
      assertFileContent home-files/.config/sway/config \
        ${./sway-workspace-output-expected.conf}
    '';
  };
}
