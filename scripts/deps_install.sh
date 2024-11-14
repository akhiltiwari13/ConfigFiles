#!/bin/bash

# Update and upgrade package lists
sudo apt update -y && sudo apt upgrade -y

# Function to install with snap, fallback to apt if not available via snap
install_package() {
    local pkg="$1"
    local snap_pkg="${2:-}"
    local apt_pkg="${3:-$1}"

    if snap list "$snap_pkg" &> /dev/null || sudo snap install "$snap_pkg"; then
        echo "Installed $snap_pkg via snap."
    elif sudo apt install -y "$apt_pkg"; then
        echo "Installed $apt_pkg via apt."
    else
        echo "Failed to install $pkg. Check manually."
    fi
}

# Installations based on Brewfile
install_package bazelisk
install_package boost
install_package bottom
install_package openssl libssl-dev
install_package sqlite sqlite3
install_package catch2
install_package llvm
install_package ccls
install_package cmake
install_package universal-ctags ctags
install_package curl
install_package doxygen
install_package fd fd-find
install_package fmt
install_package fzf
install_package gdu
install_package git
install_package git-lfs
install_package gource
install_package harfbuzz libharfbuzz-dev
install_package htop
install_package httpie
install_package lazydocker
install_package lazygit
install_package lua
install_package luarocks
install_package neovim
install_package ninja-build ninja
install_package nlohmann-json3-dev
install_package nmap
install_package node nodejs
install_package nvm
install_package pandoc
install_package parallel
install_package perl
install_package python3 python3-pip
install_package qt5-default
install_package ripgrep
install_package rustup rustc
install_package tesseract-ocr
install_package silversearcher-ag
install_package tmux
install_package transmission-cli
install_package tree
install_package yarn
install_package zig

# Fonts - use manual download for nerd fonts if needed
echo "Fonts may need manual installation. Refer to Nerd Fonts website."

# GUI Apps - cask equivalents (may need manual install if not available)
install_package calibre
install_package drawio
install_package firefox
install_package google-chrome-stable
install_package microsoft-edge-stable
install_package microsoft-teams
install_package ngrok
install_package tor
install_package zoom-client

# VSCode Extensions (requires VSCode CLI to be installed)
if command -v code &> /dev/null; then
    echo "Installing VSCode extensions..."
    code --install-extension adpyke.codesnap
    code --install-extension asvetliakov.vscode-neovim
    code --install-extension bracketpaircolordlw.bracket-pair-color-dlw
    code --install-extension ccls-project.ccls
    code --install-extension cschlosser.doxdocgen
    code --install-extension davidanson.vscode-markdownlint
    code --install-extension eamodio.gitlens
    code --install-extension github.vscode-pull-request-github
    code --install-extension ibm.output-colorizer
    code --install-extension jeff-hykin.better-cpp-syntax
    code --install-extension llvm-vs-code-extensions.vscode-clangd
    code --install-extension mechatroner.rainbow-csv
    code --install-extension ms-python.debugpy
    code --install-extension ms-python.isort
    code --install-extension ms-python.python
    code --install-extension ms-python.vscode-pylance
    code --install-extension ms-vscode.cmake-tools
    code --install-extension ms-vscode.cpptools
    code --install-extension naumovs.color-highlight
    code --install-extension rust-lang.rust-analyzer
    code --install-extension tomoki1207.pdf
    code --install-extension twxs.cmake
    code --install-extension vadimcn.vscode-lldb
    code --install-extension xaver.clang-format
else
    echo "VSCode CLI 'code' not found. Skipping VSCode extensions."
fi

echo "Installation script complete. Please check for any errors above."
