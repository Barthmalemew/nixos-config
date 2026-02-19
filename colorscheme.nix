# Central color palette for the entire system.
# EVA Unit-02: red, orange, black, gray, white, green (focus only).
# Every module (wezterm, nvim, opencode, quickshell, niri, ...) imports
# this single file so colors only need to be changed in one place.
{
  # Backgrounds — dark to darkest
  base          = "#34363a";   # main bg  — warm charcoal
  surface       = "#26272a";   # panels   — slightly darker
  overlay       = "#1f2022";   # overlays — darkest surface

  # Text — white family
  text          = "#efeae4";   # primary  — warm cream
  subtle        = "#b9b4ae";   # secondary — muted warm gray
  muted         = "#7a7c80";   # faded    — dim gray for comments/borders

  # Accents — Unit-02 armor
  red           = "#c24f4f";   # EVA-02 armor red
  orange        = "#d17936";   # EVA-02 warm orange

  # Functional — focus/active only
  green         = "#a8ff00";   # Unit-02 eye green — focus indicators
  greenDim      = "#7acc00";   # dimmed eye green

  # Highlights — background variations
  highlightLow  = "#2a2c30";   # subtle selection — just above surface
  highlightMed  = "#3e3234";   # visual selection — warm dark red tint
  highlightHigh = "#d17936";   # bright highlight — matches orange
}
