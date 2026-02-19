function fish_prompt --description Hydro
    if set -q _hydro_prompt_newline
        echo
    else
        set -g _hydro_prompt_newline
    end
    echo -e -n "$_hydro_color_start$hydro_symbol_start$hydro_color_normal$_hydro_color_pwd$_hydro_pwd$hydro_color_normal $_hydro_color_git$$_hydro_git$hydro_color_normal$_hydro_color_duration$_hydro_cmd_duration$hydro_color_normal$_hydro_status$hydro_color_normal "
end
