#!/bin/bash
set -e

# Steam initialization script - downloads game at runtime if needed
GAME_PATH="${GAME_PATH:-/data/Stardew/game}"
SRCDS_APPID="${SRCDS_APPID:-413150}"

echo "Checking if Steam game needs to be downloaded..."

# Check if game needs to be downloaded
if [ ! -f "${GAME_PATH}/StardewValley" ]; then
    echo "Game not found. Starting Steam download..."
    
    # Validate Steam credentials
    if [ -z "$STEAM_USER" ] || [ -z "$STEAM_PASS" ]; then
        echo "ERROR: STEAM_USER and STEAM_PASS environment variables must be set!"
        echo "Please provide Steam credentials via environment variables."
        exit 1
    fi
    
    # Build Steam login command
    STEAM_CMD="/data/steamcmd/steamcmd.sh +force_install_dir ${GAME_PATH} +login ${STEAM_USER} ${STEAM_PASS}"
    
    # Add Steam Guard if provided
    if [ -n "$STEAM_GUARD" ]; then
        STEAM_CMD="${STEAM_CMD} ${STEAM_GUARD}"
    fi
    
    # Complete the command
    STEAM_CMD="${STEAM_CMD} +app_update ${SRCDS_APPID} validate +quit"
    
    echo "Downloading Stardew Valley from Steam..."
    export HOME=/data
    chown -R 1000:1000 /data
    
    # Execute Steam download
    if eval "$STEAM_CMD"; then
        echo "Steam download completed successfully!"
        
        # Copy Steam client libraries
        echo "Setting up Steam SDK libraries..."
        cp -v /data/steamcmd/linux32/steamclient.so /data/.steam/sdk32/steamclient.so
        cp -v /data/steamcmd/linux64/steamclient.so /data/.steam/sdk64/steamclient.so
        
        # Install SMAPI
        echo "Installing SMAPI..."
        SMAPI_INSTALLER=$(find /data/nexus -name 'SMAPI*.*Installer' -type f -path "*/SMAPI * installer/internal/linux/*" | head -n 1)
        if [ -n "$SMAPI_INSTALLER" ]; then
            SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true echo -e '2\n\n' | "$SMAPI_INSTALLER" --install --game-path "$GAME_PATH" || echo "SMAPI installation completed with warnings"
        else
            echo "WARNING: SMAPI installer not found!"
        fi
        
        # Copy mods from template
        echo "Setting up mods..."
        if [ -d "/data/Stardew/mods_template" ] && [ "$(ls -A /data/Stardew/mods_template 2>/dev/null)" ]; then
            mkdir -p "${GAME_PATH}/Mods"
            cp -r /data/Stardew/mods_template/* "${GAME_PATH}/Mods/" 2>/dev/null || true
        fi
        
        # Copy start script
        if [ -f "/data/Stardew/start.sh.template" ]; then
            cp /data/Stardew/start.sh.template "${GAME_PATH}/start.sh"
            chmod +x "${GAME_PATH}/start.sh"
        fi
        
        # Set permissions
        echo "Setting permissions..."
        chmod +x "${GAME_PATH}/StardewValley" 2>/dev/null || true
        chmod -R 777 "${GAME_PATH}"
        chown -R 1000:1000 /data/Stardew
        
        echo "Game initialization completed!"
    else
        echo "ERROR: Steam download failed!"
        echo "Please check your Steam credentials and try again."
        exit 1
    fi
else
    echo "Game already downloaded, skipping Steam initialization."
fi
