#!/bin/bash

set -e  # Exit on any error
set -o pipefail  # Catch errors in piped commands

# Define paths
GOROOT=$(go env GOROOT)
WASM_EXEC_SRC="$GOROOT/misc/wasm/wasm_exec.js"
WASM_EXEC_DEST="./frontend/js/"

TAILWIND_URL="https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-linux-x64"
TAILWIND_DEST="./frontend/css/tailwindcss"

# Ensure the destination directory exists
mkdir -p "$WASM_EXEC_DEST"
mkdir -p "./frontend/css"

# Copy wasm_exec.js
echo "Copying wasm_exec.js from $WASM_EXEC_SRC to $WASM_EXEC_DEST..."
if [ -f "$WASM_EXEC_SRC" ]; then
    cp "$WASM_EXEC_SRC" "$WASM_EXEC_DEST"
    echo "✅ wasm_exec.js copied successfully!"
else
    echo "❌ Error: wasm_exec.js not found at $WASM_EXEC_SRC"
    exit 1
fi

# Download TailwindCSS binary
echo "Downloading TailwindCSS..."
if curl -L "$TAILWIND_URL" -o "$TAILWIND_DEST"; then
    chmod +x "$TAILWIND_DEST"
    echo "✅ TailwindCSS downloaded and made executable!"
else
    echo "❌ Error: Failed to download TailwindCSS."
    exit 1
fi

# Check if package.json exists
if [ -f "package.json" ]; then
    echo "Installing NPM dependencies..."
    if npm install; then
        echo "✅ NPM dependencies installed successfully!"
    else
        echo "❌ Error: Failed to install NPM dependencies."
        exit 1
    fi
else
    echo "⚠️ Warning: No package.json found. Skipping NPM install."
fi

echo "🎉 Setup complete!"
