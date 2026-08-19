#!/usr/bin/env bash
set -euo pipefail

missing_packages=()
command -v wget >/dev/null 2>&1 || missing_packages+=(wget)
command -v unzip >/dev/null 2>&1 || missing_packages+=(unzip)
command -v xvfb-run >/dev/null 2>&1 || missing_packages+=(xvfb)

if [ "${#missing_packages[@]}" -gt 0 ]; then
  if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
    sudo sed -i \
      -e 's|mirror+file:/etc/apt/apt-mirrors.txt|https://archive.ubuntu.com/ubuntu/|g' \
      -e 's|http://azure.archive.ubuntu.com/ubuntu|https://archive.ubuntu.com/ubuntu|g' \
      /etc/apt/sources.list.d/ubuntu.sources
  fi
  if [ -f /etc/apt/sources.list ]; then
    sudo sed -i \
      -e 's|http://azure.archive.ubuntu.com/ubuntu|https://archive.ubuntu.com/ubuntu|g' \
      /etc/apt/sources.list
  fi
  timeout 180s sudo apt-get \
    -o Acquire::Retries=3 \
    -o Acquire::http::Timeout=20 \
    -o Acquire::https::Timeout=20 \
    update
  timeout 180s sudo apt-get \
    -o Acquire::Retries=3 \
    -o Acquire::http::Timeout=20 \
    -o Acquire::https::Timeout=20 \
    install -y --no-install-recommends "${missing_packages[@]}"
fi

mkdir -p tools/godot
godot_bin="tools/godot/$GODOT_BIN_NAME"
if [ ! -x "$godot_bin" ]; then
  wget -O "tools/godot/$GODOT_ZIP_NAME" "$GODOT_DOWNLOAD_URL"
  unzip -o "tools/godot/$GODOT_ZIP_NAME" -d tools/godot "$GODOT_BIN_NAME"
  rm -f "tools/godot/$GODOT_ZIP_NAME"
  chmod +x "$godot_bin"
fi
