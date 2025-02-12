# Pull base image.
FROM jlesage/baseimage-gui:debian-11

# Set build-time arguments.
ARG STEAM_USER
ARG STEAM_PASS
ARG SRCDS_APPID
ARG STEAM_GUARD

# Set environment variables.
ENV APP_NAME="StardewValley" \
    GAME_PATH="/data/Stardew/game" \
    USER_ID=1000 \
    GROUP_ID=1000

# Install necessary packages.
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    tar \
    strace \
    mono-complete \
    xterm \
    gettext-base \
    jq \
    netcat \
    procps \
    lib32gcc-s1 \
    locales \
    dos2unix && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create necessary directories.
RUN mkdir -p ${GAME_PATH} /data/nexus /data/steamcmd /opt /config

# Ensure /config exists and is writable.
RUN chown -R ${USER_ID}:${GROUP_ID} /config && chmod -R 775 /config

# Download and install SteamCMD; then run it to install the game.
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -qO /tmp/steamcmd_linux.tar.gz && \
    tar -xzvf /tmp/steamcmd_linux.tar.gz -C /data/steamcmd && \
    cd /data/steamcmd && \
    ./steamcmd.sh +quit && \
    chown -R ${USER_ID}:${GROUP_ID} /data && \
    export HOME=/data && \
    ./steamcmd.sh +force_install_dir ${GAME_PATH} +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_GUARD} +app_update ${SRCDS_APPID} validate +quit && \
    rm -rf /tmp/steamcmd_linux.tar.gz /data/steamcmd

# Install SMAPI 4.1.10 and clean up after.
RUN wget https://github.com/Pathoschild/SMAPI/releases/download/4.1.10/SMAPI-4.1.10-installer.zip -qO /tmp/SMAPI-installer.zip && \
    unzip /tmp/SMAPI-installer.zip -d /data/nexus/ && \
    SMAPI_INSTALLER=$(find /data/nexus -name 'SMAPI*.*Installer' -type f -path "*/SMAPI * installer/internal/linux/*" | head -n 1) && \
    /bin/bash -c "SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true echo -e '2\n\n' | \"$SMAPI_INSTALLER\" --install --game-path \"$GAME_PATH\"" || : && \
    rm -rf /tmp/SMAPI-installer.zip /data/nexus

# Ensure Steam client libraries are correctly copied.
RUN mkdir -p /data/.steam/sdk32 && \
    cp -v /data/steamcmd/linux32/steamclient.so /data/.steam/sdk32/steamclient.so || true && \
    mkdir -p /data/.steam/sdk64 && \
    cp -v /data/steamcmd/linux64/steamclient.so /data/.steam/sdk64/steamclient.so || true

# Copy mods and auxiliary scripts.
COPY ["mods/", "$GAME_PATH/Mods/"]
COPY scripts/ /opt/

# Set proper permissions for game files and scripts.
RUN chmod +x $GAME_PATH/StardewValley && \
    chmod -R 777 $GAME_PATH && \
    chown -R ${USER_ID}:${GROUP_ID} /data/Stardew && \
    chmod +x /opt/*.sh

# Setup services for the base image.
RUN mkdir -p /etc/services.d/utils && touch /etc/services.d/app/utils.dep
COPY run /etc/services.d/utils/run
RUN chmod +x /etc/services.d/utils/run

# Copy and set up the game start script.
COPY start.sh $GAME_PATH/start.sh
RUN chmod +x $GAME_PATH/start.sh

# Copy the entry point script.
COPY docker-entrypoint-steam.sh /startapp.sh
RUN chmod +x /startapp.sh

# Convert line endings of all shell scripts to LF.
RUN dos2unix /startapp.sh /opt/*.sh $GAME_PATH/start.sh

# Ensure the game and config directories have correct ownership and permissions.
RUN chown -R ${USER_ID}:${GROUP_ID} /data/Stardew /config && chmod -R 775 /data/Stardew /config

# Debug: List key files and directories.
RUN ls -la /startapp.sh && ls -la /opt && ls -la $GAME_PATH
