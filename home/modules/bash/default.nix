{ pkgs, colorscheme, ... }:

let
  c = colorscheme;
in
{
  # ~/.blerc is sourced by ble.sh during ble-attach, after all modules are
  # loaded — the correct place for ble-face settings.
  home.file.".blerc".text = ''
    # ── Editing / UI faces ─────────────────────────────────────────────────
    ble-face -s region                    "fg=${c.text},bg=${c.highlightMed}"
    ble-face -s region_target             "fg=${c.text},bg=${c.highlightLow}"
    ble-face -s region_match              "fg=${c.text},bg=${c.overlay}"
    ble-face -s region_insert             "fg=${c.green},bg=${c.surface}"
    ble-face -s disabled                  "fg=${c.muted}"
    ble-face -s overwrite_mode            "fg=${c.base},bg=${c.orange}"
    ble-face -s vbell                     "reverse"
    ble-face -s vbell_erase               "bg=${c.surface}"
    ble-face -s vbell_flash               "fg=${c.green},reverse"
    ble-face -s prompt_status_line        "fg=${c.text},bg=${c.surface}"

    # ── Syntax faces ───────────────────────────────────────────────────────
    ble-face -s syntax_default            "fg=${c.text}"
    ble-face -s syntax_command            "fg=${c.green},bold"
    ble-face -s syntax_quoted             "fg=${c.text}"
    ble-face -s syntax_quotation          "fg=${c.orange},bold"
    ble-face -s syntax_escape             "fg=${c.red},bold"
    ble-face -s syntax_expr               "fg=${c.subtle}"
    ble-face -s syntax_error              "fg=${c.red},bold"
    ble-face -s syntax_varname            "fg=${c.orange},bold"
    ble-face -s syntax_delimiter          "fg=${c.subtle}"
    ble-face -s syntax_param_expansion    "fg=${c.orange}"
    ble-face -s syntax_history_expansion  "fg=${c.orange},bg=${c.overlay}"
    ble-face -s syntax_function_name      "fg=${c.green},underline"
    ble-face -s syntax_comment            "fg=${c.muted},italic"
    ble-face -s syntax_glob               "fg=${c.orange},bold"
    ble-face -s syntax_brace              "fg=${c.orange},bold"
    ble-face -s syntax_tilde              "fg=${c.subtle}"
    ble-face -s syntax_document           "fg=${c.text}"
    ble-face -s syntax_document_begin     "fg=${c.orange},bold"

    # ── Command-type faces ─────────────────────────────────────────────────
    ble-face -s command_builtin_dot       "fg=${c.orange},bold"
    ble-face -s command_builtin           "fg=${c.orange}"
    ble-face -s command_alias             "fg=${c.greenDim}"
    ble-face -s command_function          "fg=${c.green}"
    ble-face -s command_file              "fg=${c.green}"
    ble-face -s command_keyword           "fg=${c.orange}"
    ble-face -s command_jobs              "fg=${c.red}"
    ble-face -s command_directory         "fg=${c.text},underline"

    # ── Filename faces ─────────────────────────────────────────────────────
    ble-face -s filename_directory        "fg=${c.text},underline"
    ble-face -s filename_directory_sticky "fg=${c.orange},underline"
    ble-face -s filename_link             "fg=${c.greenDim},underline"
    ble-face -s filename_orphan           "fg=${c.red},underline"
    ble-face -s filename_executable       "fg=${c.green},underline"
    ble-face -s filename_setuid           "fg=${c.red},underline"
    ble-face -s filename_setgid           "fg=${c.orange},underline"
    ble-face -s filename_other            "fg=${c.text},underline"
    ble-face -s filename_socket           "fg=${c.orange},underline"
    ble-face -s filename_pipe             "fg=${c.orange},underline"
    ble-face -s filename_character        "fg=${c.text},underline"
    ble-face -s filename_block            "fg=${c.orange},underline"
    ble-face -s filename_warning          "fg=${c.red},underline"
    ble-face -s filename_url              "fg=${c.greenDim},underline"
    ble-face -s filename_ls_colors        "fg=${c.text},underline"

    # ── Variable-name faces (shown in completions) ─────────────────────────
    ble-face -s varname_array             "fg=${c.orange},bold"
    ble-face -s varname_empty             "fg=${c.muted}"
    ble-face -s varname_export            "fg=${c.orange},bold"
    ble-face -s varname_expr              "fg=${c.orange},bold"
    ble-face -s varname_hash              "fg=${c.greenDim},bold"
    ble-face -s varname_number            "fg=${c.greenDim}"
    ble-face -s varname_readonly          "fg=${c.red}"
    ble-face -s varname_transform         "fg=${c.greenDim},bold"
    ble-face -s varname_unset             "fg=${c.muted}"

    # ── Argument faces ─────────────────────────────────────────────────────
    ble-face -s argument_option           "fg=${c.orange}"
    ble-face -s argument_error            "fg=${c.red}"

    # ── Completion faces ───────────────────────────────────────────────────
    ble-face -s auto_complete             "fg=${c.muted}"
    blehook/eval-after-load complete 'ble-face -s menu_filter_fixed bold'
    blehook/eval-after-load complete 'ble-face -s menu_filter_input "fg=${c.text},bg=${c.surface}"'
  '';

  programs.bash = {
    enable = true;

    initExtra = ''
      # ── ble.sh ─────────────────────────────────────────────────────────────
      # --attach=prompt defers attachment until bash enters its readline loop,
      # i.e. after .bashrc is fully done — preventing a double prompt render.
      [[ $- == *i* ]] && source -- ${pkgs.blesh}/share/blesh/ble.sh --attach=prompt

      # ── Prompt (based on Lissy93/minimal-terminal-prompt) ───────────────────
      # Defined before wezterm.sh so that __wezterm_semantic_precmd wraps the
      # already-correct PS1 with OSC 133 zones rather than stomping it.
      RESET='\[\e[0m\]'
      BOLD='\[\e[1m\]'
      COL_USER='\[\e[38;2;209;121;54m\]'
      COL_HOST='\[\e[38;2;194;79;79m\]'
      COL_PATH='\[\e[38;2;239;234;228m\]'
      COL_META='\[\e[38;2;122;124;128m\]'
      COL_CURSOR='\[\e[38;2;209;121;54m\]'
      COL_GIT_STATUS_CLEAN='\[\e[38;2;122;204;0m\]'
      COL_GIT_STATUS_CHANGES='\[\e[38;2;209;121;54m\]'

      __eva_parse_git_branch() {
        git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
      }

      __eva_parse_git_changes() {
        if [[ -n $(git status --porcelain --ignore-submodules=dirty 2>/dev/null) ]]; then
          printf '%s' "$COL_GIT_STATUS_CHANGES"
        else
          printf '%s' "$COL_GIT_STATUS_CLEAN"
        fi
      }

      __eva_git_segment() {
        [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == true ]] || return 0
        local branch color
        branch=$(__eva_parse_git_branch) || return 0
        [[ $branch ]] || return 0
        color=$(__eva_parse_git_changes)
        printf ' %s(%s%s%s)%s' "$COL_META" "$color" "$branch" "$COL_META" "$RESET"
      }

      __eva_set_bash_prompt() {
        local git_segment
        git_segment=$(__eva_git_segment)
        PS1="$RESET$BOLD$COL_USER\u$RESET $COL_META@ $RESET$BOLD$COL_HOST\h$RESET $COL_PATH\w$RESET$git_segment\n$COL_CURSOR└─▶ $RESET"
      }

      if [[ -n ''${BLE_VERSION-} ]]; then
        if [[ -z ''${__eva_prompt_hook_added-} ]]; then
          blehook PRECMD+=__eva_set_bash_prompt
          __eva_prompt_hook_added=1
        fi
      elif [[ ''${PROMPT_COMMAND-} != *"__eva_set_bash_prompt"* ]]; then
        if [[ -n ''${PROMPT_COMMAND-} ]]; then
          PROMPT_COMMAND="__eva_set_bash_prompt"$'\n'"''${PROMPT_COMMAND}"
        else
          PROMPT_COMMAND="__eva_set_bash_prompt"
        fi
      fi

      # ── Wezterm shell integration ───────────────────────────────────────────
      # Sourced after the prompt is defined so __wezterm_semantic_precmd appends
      # OSC 133 zones to the correct PS1 rather than overwriting it.
      source -- ${pkgs.wezterm}/etc/profile.d/wezterm.sh

      # ── direnv ─────────────────────────────────────────────────────────────
      # Evaluated here (not via enableBashIntegration) to keep ordering explicit.
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';
  };
}
