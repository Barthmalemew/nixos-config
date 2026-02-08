{ pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # GIT CONFIGURATION
  # ---------------------------------------------------------------------------
  # This module generates the global ~/.gitconfig file.
  # Using Home Manager for this allows us to:
  # 1. Keep the config version-controlled.
  # 2. Automatically install 'git' and 'delta' (a syntax highlighter).
  # 3. Ensure consistency across all your machines.

  programs.git = {
    enable = true;

    # Basic user identity
    settings = {
      user = {
        name = "barthmalemew";
        email = "kevinrouse105@gmail.com";
      };
      
      # Best Practices:
      # - 'main' is the standard default branch name now.
      # - 'rebase = true' keeps your history linear and clean when pulling.
      # - 'autoSetupRemote' saves you from typing "--set-upstream" every time.
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Delta provides a much better looking "diff" in the terminal.
  # It adds syntax highlighting and side-by-side comparisons.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;    # Use n/N to jump between diff sections
      line-numbers = true;
    };
  };
}
