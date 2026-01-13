#!/bin/bash

# Define the bash configuration file
CONFIG_FILE="$HOME/.bashrc"

# Marker to check if the block already exists
MARKER="# ===== Ryuyx's Aliases ====="

# Define the shell functions instead of aliases to handle arguments ($1) correctly
ALIASES=(
    "set-proxy() { export http_proxy=\"\$1\"; export https_proxy=\"\$1\"; }"
    "unset-proxy() { unset http_proxy; unset https_proxy; }"
)

# Check if the marker already exists in the config file
if grep -Fq "$MARKER" "$CONFIG_FILE" 2>/dev/null; then
    echo "Aliases already exist in $CONFIG_FILE"
    echo "Skipping..."
else
    echo "Adding aliases to $CONFIG_FILE..."

    # Append the block to the config file
    {
        echo ""
        echo "$MARKER"
        for alias_line in "${ALIASES[@]}"; do
            echo "$alias_line"
        done
        echo "# ===== End ====="
    } >> "$CONFIG_FILE"

    echo "Done! Configuration written to file."
    
    # --- Color Output Section ---
    # Define color codes
    GREEN='\033[0;32m'  # Green text
    NC='\033[0m'        # No Color (resets to default)

    # Print the command in green
    echo -e "Please run the following command to apply changes or restart your terminal:"
    echo -e "${GREEN}  source $CONFIG_FILE${NC}"
    # ----------------------------
fi
