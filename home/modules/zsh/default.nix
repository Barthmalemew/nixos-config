{ colorscheme, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # Prompt: username@hostname ~/dir %
      PROMPT='%F{${colorscheme.orange}}%n%f%F{${colorscheme.muted}}@%f%F{${colorscheme.red}}%m%f %F{${colorscheme.text}}%~%f %F{${colorscheme.green}}%#%f '

      # Autosuggestion ghost-text color
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${colorscheme.muted}"

      # Syntax highlighting colors
      typeset -A ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[default]="fg=${colorscheme.text}"
      ZSH_HIGHLIGHT_STYLES[unknown-command]="fg=${colorscheme.red}"
      ZSH_HIGHLIGHT_STYLES[command]="fg=${colorscheme.green}"
      ZSH_HIGHLIGHT_STYLES[builtin]="fg=${colorscheme.green}"
      ZSH_HIGHLIGHT_STYLES[function]="fg=${colorscheme.green}"
      ZSH_HIGHLIGHT_STYLES[alias]="fg=${colorscheme.greenDim}"
      ZSH_HIGHLIGHT_STYLES[precommand]="fg=${colorscheme.orange},bold"
      ZSH_HIGHLIGHT_STYLES[reserved-word]="fg=${colorscheme.orange}"
      ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${colorscheme.orange}"
      ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${colorscheme.orange}"
      ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]="fg=${colorscheme.orange}"
      ZSH_HIGHLIGHT_STYLES[path]="fg=${colorscheme.text},underline"
      ZSH_HIGHLIGHT_STYLES[globbing]="fg=${colorscheme.orange}"
      ZSH_HIGHLIGHT_STYLES[comment]="fg=${colorscheme.muted}"
      ZSH_HIGHLIGHT_STYLES[history-expansion]="fg=${colorscheme.orange}"
      ZSH_HIGHLIGHT_STYLES[assign]="fg=${colorscheme.text}"
    '';
  };
}
