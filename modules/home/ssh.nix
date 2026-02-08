{ ... }:

{
  # ---------------------------------------------------------------------------
  # SSH CONFIGURATION
  # ---------------------------------------------------------------------------
  # Manage SSH keys and host aliases declaratively.
  
  programs.ssh = {
    enable = true;
    
    # "false" allows you to still have a ~/.ssh/config that isn't managed by Nix
    # if you need it, but we are managing specific blocks below.
    enableDefaultConfig = false;

    matchBlocks = {
      # Apply these settings to ALL hosts
      "*" = {
        addKeysToAgent = "yes"; # Avoid typing passwords repeatedly
      };
      
      # Specific settings for GitHub to ensure the correct key is used
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true; # Don't try every key you have, only this one
      };
    };
  };

  # SSH Agent
  # This systemd service ensures the SSH agent is running in the background,
  # holding your keys in memory so you don't have to unlock them constantly.
  services.ssh-agent.enable = true;
}
