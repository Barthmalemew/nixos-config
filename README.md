# ❄️ NixOS Configuration (Unit-02 Theme)

This is the personal NixOS configuration for **Barthmalemew**.
It features a custom **Evangelion Unit-02** theme, **Niri** (Window Manager), and **Quickshell** (UI).

## 🖼️ Gallery
*(Add screenshots here)*

## 🛠️ Stack
- **OS:** NixOS (Unstable)
- **WM:** [Niri](https://github.com/YaLTeR/niri) (Scrollable Tiling)
- **Shell:** [Quickshell](https://github.com/outfoxxed/quickshell) (Qt/QML Overlay)
- **Editor:** [NVF](https://github.com/notashelf/nvf) (Neovim Flake)
- **Terminal:** Foot
- **Browser:** Vivaldi

## 🚀 Installation

### 1. Clone
```bash
git clone https://github.com/Barthmalemew/nixos-config.git ~/nixos-config
cd ~/nixos-config
```

### 2. Select Host
*   **Desktop:** `ladmin`
*   **Laptop:** `ladmin-laptop`

### 3. Install
```bash
# First run
sudo nixos-rebuild switch --flake .#ladmin-laptop

# Subsequent updates (using alias)
rebuild
```

## 📂 Structure
*   `flake.nix`: Entry point.
*   `hosts/`: Hardware-specific configurations (Monitors, Power).
*   `modules/`: Custom modules for system + Home Manager.
*   `home.nix`: Home Manager entry (imports focused modules).
*   `config/`: Dotfile templates (Niri base KDL, Quickshell, Foot).
*   `nvf/`: Standalone Neovim configuration.

## 🎨 Theming
The theme is centralized in `modules/theme.nix`.
Changing a color there updates Niri borders, Quickshell UI, Terminal colors, and Neovim theme simultaneously.

## 🧭 Notes
- Niri uses a template at `config/niri/config.kdl`. Nix injects host monitor outputs
  and theme colors via `config/niri/config.nix` and writes the final file to
  `~/.config/niri/config.kdl`.
- Quickshell stays as plain QML files in `config/quickshell/`. The only Nix
  generation is `config/quickshell/theme/Colors.qml`, which maps the theme palette
  into QML properties.
