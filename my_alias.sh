#!/bin/bash

# This script is used to add aliases to the user's shell configuration file
CONFIG_FILE="$HOME/.bashrc"  # For bash

# Aliases to be added
ALIASES=(
    "alias set-proxy='export http_proxy=\$1; export https_proxy=\$1'"
    "alias unset-proxy='unset http_proxy; unset https_proxy'"
)

if grep -q "# ===== Ryuyx's Aliases =====" "$CONFIG_FILE"; then
    echo "Aliases already exist in $CONFIG_FILE"
    echo "Skipping..."
else
    echo "Adding aliases to $CONFIG_FILE..."
    echo "" >> "$CONFIG_FILE"
    echo "# ===== Ryuyx's Aliases =====" >> "$CONFIG_FILE"
    for alias_line in "${ALIASES[@]}"; do
        echo "$alias_line" >> "$CONFIG_FILE"
    done
    echo "# ===== End =====" >> "$CONFIG_FILE"
    
    echo "Done! Aliases have been added."
fi

source "$CONFIG_FILE"
