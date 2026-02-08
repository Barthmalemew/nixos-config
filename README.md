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
*   `modules/`: Custom NixOS modules (Theme system).
*   `home.nix`: User-space configuration (Apps, Services).
*   `config/`: Dotfiles templates (Niri, Quickshell, Foot).
*   `nvf/`: Standalone Neovim configuration.

## 🎨 Theming
The theme is centralized in `modules/theme.nix`.
Changing a color there updates Niri borders, Quickshell UI, Terminal colors, and Neovim theme simultaneously.
