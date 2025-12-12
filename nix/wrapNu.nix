{
  pkgs,
  lib,
  prevNushell,
  ...
}: let
  conf = import ./config.nix {inherit pkgs lib;};
in
  pkgs.symlinkJoin {
    paths = [prevNushell];
    buildInputs = [pkgs.makeWrapper];

    inherit (prevNushell) version src cargoHash pname passthru meta;

    postBuild = ''
      mkdir -p $out/etc/nu-config
      cp -r ${../nu-config}/* $out/etc/nu-config

      # create a plugin registry file
      ${lib.getExe prevNushell} \
          --plugin-config "$out/etc/nu-config/plugin.msgpackz" \
          --commands '${
            lib.concatStringsSep "; " (map (plugin: "plugin add ${lib.getExe plugin}") conf.plugins)
      }'

      cp ${pkgs.writeText "init.nu" /*nu*/ ''
        # source non nix dependent nu-config
        source ./config.nu

        # source nix inline configuration
        ${conf.extraConfig}
      ''} $out/etc/nu-config/init.nu

      wrapProgram $out/bin/nu \
        --prefix PATH : "${lib.makeBinPath conf.extraPackages}" \
        --add-flags "--plugin-config $out/etc/nu-config/plugin.msgpackz" \
        --add-flags "--config $out/etc/nu-config/init.nu"
    '';
  }
