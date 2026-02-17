{ ... }:

{
  xdg.configFile."quickshell" = {
    source = ./.;
    recursive = true;
  };
}
