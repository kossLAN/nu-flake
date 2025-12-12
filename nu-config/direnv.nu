# taken from https://github.com/nix-community/home-manager/blob/release-25.11/modules/programs/direnv.nix
$env.config = ($env.config? | default {})
$env.config.hooks = ($env.config.hooks? | default {})
$env.config.hooks.pre_prompt = (
  $env.config.hooks.pre_prompt?
  | default []
  | append {||
      direnv export json
      | from json --strict
      | default {}
      | items {|key, value|
          let value = do (
              {
                "PATH": {
                  from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                  to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
                }
              }
              | merge ($env.ENV_CONVERSIONS? | default {})
              | get ([[value, optional, insensitive]; [$key, true, true] [from_string, true, false]] | into cell-path)
              | if ($in | is-empty) { {|x| $x} } else { $in }
          ) $value
          return [ $key $value ]
      }
      | into record
      | load-env
  }
)
