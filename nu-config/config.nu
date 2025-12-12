source ./prompt.nu
source ./direnv.nu

$env.config = ($env.config | default {} | merge { 
    show_banner: false # hide startup banner
    highlight_resolved_externals: true # syntax highlighting for valid binaries
    color_config: {
        shape_internalcall: "g"
        shape_external: "r"
        shape_external_resolved: "g"
        shape_externalarg: "w"
        shape_string: "y"
        shape_operator: "cb"
        shape_variable: "c"
        shape_filepath: "cu"
        shape_pipe: "c"
        shape_garbage: { fg: "lr" attr: "b" }
        hints: "b"
        foreground: "w"
    }
})
