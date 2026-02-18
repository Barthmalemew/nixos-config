{ pkgs, colorscheme, ... }:

let
  c = colorscheme;

  opencodeConfig = {
    "$schema" = "https://opencode.ai/config.json";
    theme = "system";
    permission = {
      bash = "ask";
      edit = "ask";
      external_directory = "ask";
      glob = "allow";
      grep = "allow";
      list = "allow";
      read = "allow";
      task = "ask";
      webfetch = "ask";
    };
    plugin = [
      "opencode-gemini-auth@latest"
    ];
  };

  opencodeTheme = builtins.toJSON {
    "$schema" = "https://opencode.ai/theme.json";
    defs = {
      inherit (c) base surface overlay text subtle muted;
      inherit (c) red orange;
      inherit (c) green greenDim;
      inherit (c) highlightLow highlightMed;
    };
    theme = {
      primary           = "red";
      secondary         = "orange";
      accent            = "orange";
      error             = "red";
      warning           = "orange";
      success           = "green";
      info              = "subtle";
      text              = "text";
      textMuted         = "muted";
      background        = "base";
      backgroundPanel   = "overlay";
      backgroundElement = "surface";
      border            = "muted";
      borderActive      = "green";
      borderSubtle      = "highlightMed";

      # Diff
      diffAdded              = "green";
      diffRemoved            = "red";
      diffContext             = "muted";
      diffHunkHeader         = "muted";
      diffHighlightAdded     = "green";
      diffHighlightRemoved   = "red";
      diffAddedBg            = "highlightLow";
      diffRemovedBg          = "highlightMed";
      diffContextBg          = "overlay";
      diffLineNumber         = "muted";
      diffAddedLineNumberBg  = "highlightLow";
      diffRemovedLineNumberBg = "highlightMed";

      # Markdown
      markdownText            = "text";
      markdownHeading         = "orange";
      markdownLink            = "subtle";
      markdownLinkText        = "subtle";
      markdownCode            = "orange";
      markdownBlockQuote      = "muted";
      markdownEmph            = "red";
      markdownStrong          = "orange";
      markdownHorizontalRule  = "muted";
      markdownListItem        = "orange";
      markdownListEnumeration = "red";
      markdownImage           = "subtle";
      markdownImageText       = "subtle";
      markdownCodeBlock       = "text";

      # Syntax
      syntaxComment     = "muted";
      syntaxKeyword     = "red";
      syntaxFunction    = "orange";
      syntaxVariable    = "text";
      syntaxString      = "orange";
      syntaxNumber      = "red";
      syntaxType        = "orange";
      syntaxOperator    = "subtle";
      syntaxPunctuation = "subtle";
    };
  };
in
{
  home.packages = [ pkgs.opencode ];

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON opencodeConfig;
  xdg.configFile."opencode/config.json".text = builtins.toJSON opencodeConfig;
  xdg.configFile."opencode/themes/system.json".text = opencodeTheme;
}
