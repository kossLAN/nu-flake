def shorten-path [] {
    let cwd = (pwd)
    let home = ($env.HOME | default "")

    if $home != "" and ($cwd | str starts-with $home) {
        $cwd | str replace --regex $"^($home)" "~"
    } else {
        $cwd
    }
}

def prompt-left [] {
    let path = (shorten-path)
    $"(ansi cyan)($path)(ansi reset)  "
}


def prompt-right [] {
    let git_info = (gstat)

    if $git_info.repo_name == "no_repository" {
        return ""
    }

    let has_changes = (
        $git_info.wt_untracked > 0 or 
        $git_info.wt_modified > 0 or 
        $git_info.wt_deleted > 0 or
        $git_info.wt_type_changed > 0 or
        $git_info.wt_renamed > 0
    )

    let status_indicator = if $has_changes {
        $"(ansi red)✘✘✘(ansi reset)"
    } else {
        $"(ansi green)✔(ansi reset)"
    }

    $"(ansi reset)\((ansi cyan)($git_info.branch)(ansi reset)\)($status_indicator)"
}

$env.PROMPT_COMMAND = { prompt-left }
$env.PROMPT_COMMAND_RIGHT = { prompt-right }
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ""
$env.PROMPT_INDICATOR_VI_NORMAL = ""
$env.MULTI_LINE_INDICATOR = "::: "
