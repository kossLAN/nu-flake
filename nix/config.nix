{
  lib,
  pkgs,
  ...
}: let
  carapace = lib.getExe pkgs.carapace;
in {
  extraPackages = with pkgs; [
    direnv
    # fzf waiting on first party support https://github.com/junegunn/fzf/pull/4630
  ];

  plugins = with pkgs.nushellPlugins; [
    gstat # git info
  ];

  extraConfig = /*nu*/
  ''
    # integrate carapace
    source ${
      pkgs.runCommand "carapace-nushell-config.nu" {} ''
        ${carapace} _carapace nushell | sed 's|"/homeless-shelter|$"($env.HOME)|g' >> "$out"
      ''
    }

    let carapace_completer = {|spans|
      let cmd_tokens = ($spans | each {|s| $s })

      let carapace_json = (
        (${carapace} $cmd_tokens.0 nushell ...$cmd_tokens) | from json
      )

      let hist_values = (
        history
        | get command
        | where $it != ""
        | first 50
      )

      let hist_completions = (
        $hist_values
        | each {|c| { value: $c, description: "recent" } }
      )

      { completions: ($hist_completions + $carapace_json) }
    }

    $env.config = ($env.config | default {} | merge {
        completions: {
            case_sensitive: false # case-sensitive completions
            quick: true    # set to false to prevent auto-selecting completions
            partial: true    # set to false to prevent partial filling of the prompt
            algorithm: "fuzzy"    # prefix or fuzzy
            external: {
                # set to false to prevent nushell looking into $env.PATH to find more suggestions
                enable: true
                # set to lower can improve completion performance at the cost of omitting some options
                max_results: 100
                completer: $carapace_completer # check 'carapace_completer'
            }
        }
    })
  '';
}
