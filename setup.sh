#!/bin/bash

# Check if the script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "Error: This script must be sourced, not executed." >&2
    echo "Please run 'source setup.sh' instead." >&2
    exit 1
fi

# This script sets up the development environment for the Flutter project.
# It installs Dart, Flutter, and other necessary dependencies.
# It is intended to be sourced, e.g., `source setup.sh`, so that
# the environment variables are set in the current shell.

set -e

echo "--- Starting Environment Setup ---"

# --- Install Dart SDK ---
echo "Installing Dart SDK..."
sudo apt-get update
sudo apt-get install -y apt-transport-https wget
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'wget -qO- https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list'
sudo apt-get update
sudo apt-get install -y dart

# --- Install Flutter SDK ---
echo "Installing Flutter SDK..."
# Install prerequisites
sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Download and extract Flutter
FLUTTER_VERSION="3.35.1"
FLUTTER_SDK_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_INSTALL_DIR="/opt/flutter"

if [ ! -d "$FLUTTER_INSTALL_DIR" ]; then
  echo "Downloading Flutter SDK version ${FLUTTER_VERSION}..."
  wget -qO /tmp/flutter.tar.xz "$FLUTTER_SDK_URL"
  echo "Extracting Flutter SDK to ${FLUTTER_INSTALL_DIR}..."
  sudo mkdir -p /opt
  sudo tar xf /tmp/flutter.tar.xz -C /opt/
  rm /tmp/flutter.tar.xz
else
  echo "Flutter SDK already found at ${FLUTTER_INSTALL_DIR}."
fi

# --- Configure Environment ---
echo "Configuring environment variables..."

# Set ownership of Flutter directory
sudo chown -R $(whoami) $FLUTTER_INSTALL_DIR

# Update PATH for the current session
export PATH="$FLUTTER_INSTALL_DIR/bin:$HOME/.pub-cache/bin:$PATH"
echo "Updated PATH for current session: $PATH"

# --- Persist PATH for future sessions ---
echo "Updating shell configuration for future sessions..."
BASHRC_FILE="$HOME/.bashrc"
touch "$BASHRC_FILE" # Ensure .bashrc exists

# Add Flutter and Pub cache to PATH
COMBINED_PATH_LINE='export PATH="/opt/flutter/bin:$HOME/.pub-cache/bin:$PATH"'
if ! grep -qF -- "$COMBINED_PATH_LINE" "$BASHRC_FILE"; then
    echo '' >> "$BASHRC_FILE"
    echo '# Add Flutter and Pub cache to PATH' >> "$BASHRC_FILE"
    echo "$COMBINED_PATH_LINE" >> "$BASHRC_FILE"
    echo "Added Flutter and Pub cache to PATH in $BASHRC_FILE"
else
    echo "Flutter and Pub cache PATH already exists in $BASHRC_FILE"
fi

echo "To apply changes, run 'source $BASHRC_FILE' or start a new terminal session."

# --- Install Dependencies ---
echo "Installing project dependencies..."

# Install very_good_cli
echo "Installing very_good_cli..."
dart pub global activate very_good_cli

# Pre-download Flutter dependencies
echo "Running flutter doctor..."
flutter doctor -v

# Retrieve project packages
echo "Running flutter pub get..."
flutter pub get

# Install melos
echo "Installing melos..."
dart pub global activate melos
melos bootstrap
melos generate_packages --no-select
melos generate

echo "--- Environment Setup Complete ---"
