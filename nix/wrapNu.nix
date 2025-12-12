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

      cp ${pkgs.writeText "init.nu" /*nu*/ ''
        # load plugins
        ${lib.concatMapStrings (plugin: ''
            plugin add ${plugin}/bin/${plugin.pname}
          '')
          conf.plugins}

        # source non nix dependent nu-config
        source ./config.nu

        # source nix inline configuration
        ${conf.extraConfig}
      ''} $out/etc/nu-config/init.nu

      wrapProgram $out/bin/nu \
        --prefix PATH : "${lib.makeBinPath conf.extraPackages}" \
        --add-flags "--config $out/etc/nu-config/init.nu"
    '';
  }
