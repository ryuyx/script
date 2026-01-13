#!/bin/bash

# This script is used to add aliases to the user's shell configuration file
CONFIG_FILE="$HOME/.bashrc"  # For bash

# Aliases to be added
ALIASES=(
    "alias set-proxy='export http_proxy=$1';export https_proxy=$1'"
    "alias unset-proxy='export http_proxy;export https_proxy"
)

echo "Adding aliases to $CONFIG_FILE..."

# Add separator markers and aliases
echo "" >> "$CONFIG_FILE"
echo "# ===== Custom Aliases (Added by script on $(date)) =====" >> "$CONFIG_FILE"
for alias_line in "${ALIASES[@]}"; do
    echo "$alias_line" >> "$CONFIG_FILE"
done
echo "# ===== End of Custom Aliases =====" >> "$CONFIG_FILE"

echo "Done! Please execute the following command to make the changes take effect:"
echo "source $CONFIG_FILE"
