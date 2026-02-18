{ config, pkgs, colorscheme, ... }:

{
  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size            = 10000;
      save            = 10000;
      share           = true;    # share history across all open sessions
      extended        = true;    # save timestamps
      ignoreDups      = true;    # skip consecutive duplicates
      ignoreSpace     = true;    # skip lines starting with a space
      expireDuplicatesFirst = true;
    };

    shellAliases = {
      ls    = "ls --color=auto";
      ll    = "ls -lh --color=auto";
      la    = "ls -lah --color=auto";
      grep  = "grep --color=auto";
      ".."  = "cd ..";
      "..." = "cd ../..";
    };

    initContent = ''
      # Up/Down: history substring search (searches by whatever you've typed so far)
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # autocd: type a directory name to cd into it
      setopt autocd

      # correct: suggest corrections for mistyped commands
      setopt correct

      # No beeping
      unsetopt beep
    '';
  };

  # fzf: fuzzy finder — Ctrl+R becomes a searchable history popup
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    colors = {
      "bg+"    = colorscheme.highlightMed;
      "fg+"    = colorscheme.text;
      "hl"     = colorscheme.orange;
      "hl+"    = colorscheme.orange;
      "border" = colorscheme.muted;
      "prompt" = colorscheme.red;
      "pointer"= colorscheme.green;
      "marker" = colorscheme.green;
      "info"   = colorscheme.subtle;
      "header" = colorscheme.subtle;
    };
  };

  # Starship: cross-shell prompt, themed to EVA Unit-02 colorscheme
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;

      # Two-line prompt: info on line 1, ❯ on line 2
      format = "$directory$git_branch$git_status$nix_shell\n$character";

      directory = {
        style             = "bold ${colorscheme.orange}";
        truncation_length = 3;
        truncate_to_repo  = true;
      };

      git_branch = {
        symbol = " ";
        style  = "${colorscheme.red}";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style   = "${colorscheme.orange}";
        format  = "([$all_status$ahead_behind]($style) )";
        ahead   = "⇡\${count}";
        behind  = "⇣\${count}";
        modified = "✚\${count}";
        untracked = "?\${count}";
        staged   = "●\${count}";
        stashed  = "≡";
      };

      # Shows "❄ nix" when inside a nix develop shell
      nix_shell = {
        style      = "${colorscheme.green}";
        format     = "[$symbol]($style) ";
        symbol     = "❄ ";
        impure_msg = "";
        pure_msg   = "";
      };

      character = {
        success_symbol = "[❯](bold ${colorscheme.green})";
        error_symbol   = "[❯](bold ${colorscheme.red})";
      };

      # Disable cloud provider noise
      aws.disabled    = true;
      gcloud.disabled = true;
      azure.disabled  = true;
    };
  };
}
