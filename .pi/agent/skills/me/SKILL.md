---
name: me
description: |
  Vincent's user profile and PC environment setup. Contains information about OS,
  editor, terminal, shell, primary language, and dotfiles structure. Reference
  this when you need context about the environment or tooling.
---

# Vincent's User Profile & Environment

Use this when working with Vincent to understand their PC setup, tooling preferences,
and development environment.

## Operating System & Shell

- **OS**: macOS
- **Shell**: zsh
- **Shell Config**: Located in dotfiles directory, managed with stow

## Editor

- **Primary Editor**: Helix
- **Config Location**: Dotfiles directory (stow-managed)
- **Note**: All file edits should work seamlessly with Helix's capabilities

## Terminal

- **Terminal Emulator**: wezterm
- **Config Location**: Dotfiles directory (stow-managed)

## Package Manager

- **Primary**: Homebrew (brew)
- **Use**: For installing system tools, dependencies, and development tools

## Development

- **Primary Language**: Go
- **Other Languages**: Python, TypeScript, Bash (as needed)
- **Language Versions**: Managed via installed tools (typically via brew or go version management)

## Dotfiles & Scripts

- **Dotfiles Location**: `/Users/vincentbenoot/dotfiles` (current working directory)
- **Management**: Dotfiles are symlinked using GNU stow
- **Scripts Location**: `dotfiles/scripts/` contains custom scripts and utilities
- **Access Pattern**: Scripts can be referenced relative to dotfiles root

## Key Environment Facts

- All configuration is declarative and stow-managed
- Changes to dotfiles should work across all configured tools
- When suggesting commands or edits, assume macOS + zsh + Helix environment
- Go is the default language for development tasks unless otherwise specified
