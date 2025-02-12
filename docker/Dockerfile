# Pull base image.
FROM jlesage/baseimage-gui:debian-11

ARG STEAM_USER
ARG STEAM_PASS
ARG SRCDS_APPID

# Set the name of the application.
ENV APP_NAME="StardewValley"
# Tell the base image where the app start script is.
ENV APP_START_SCRIPT=/startapp.sh

## Uses a distinct PATH from Stardew/game/ that GOG has.
ENV GAME_PATH="/data/Stardew/game"

## lib32gcc-s1 is required for steamcmd
RUN apt-get update && apt-get install -y \
      wget unzip tar strace mono-complete xterm gettext-base jq netcat procps lib32gcc-s1 locales \
    && apt-get clean

# Create required directories.
RUN mkdir -p ${GAME_PATH} && \
    mkdir -p /data/nexus && \
    mkdir -p /data/steamcmd

## FOR STEAM VERSION
RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -qO steamcmd.tar.gz && \
    tar -xzvf steamcmd.tar.gz -C /data/steamcmd && \
    cd /data/steamcmd

## Generate en_US.UTF-8 locale required by Steam (if missing)
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales

## Update Steam to prevent Steam Guard timeout.
RUN /data/steamcmd/steamcmd.sh +quit

## Use these arguments without caching earlier steps.
ARG STEAM_GUARD
RUN chown -R 1000:1000 /data && \
    export HOME=/data && \
    /data/steamcmd/steamcmd.sh +force_install_dir ${GAME_PATH} +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_GUARD} +app_update ${SRCDS_APPID} validate +quit

RUN mkdir -p /data/.steam/sdk32 && \
    cp -v /data/steamcmd/linux32/steamclient.so /data/.steam/sdk32/steamclient.so && \
    mkdir -p /data/.steam/sdk64 && \
    cp -v /data/steamcmd/linux64/steamclient.so /data/.steam/sdk64/steamclient.so

## END STEAM VERSION
RUN wget -qO dotnet.tar.gz https://download.visualstudio.microsoft.com/download/pr/d4b71fac-a2fd-4516-ac58-100fb09d796a/e79d6c2a8040b59bf49c0d167ae70a7b/dotnet-sdk-5.0.408-linux-arm64.tar.gz && \
    tar -zxf dotnet.tar.gz -C /usr/share/dotnet && \
    rm dotnet.tar.gz && \
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

RUN wget --user-agent="Mozilla" https://github.com/Pathoschild/SMAPI/releases/download/4.1.10/SMAPI-4.1.10-installer.zip -qO /data/nexus.zip && \
    unzip /data/nexus.zip -d /data/nexus/ && \
    SMAPI_INSTALLER=$(find /data/nexus -name 'SMAPI*.*Installer' -type f -path "*/SMAPI * installer/internal/linux/*" | head -n 1) && \
    /bin/bash -c "SMAPI_NO_TERMINAL=true SMAPI_USE_CURRENT_SHELL=true echo -e '2\n\n' | \"$SMAPI_INSTALLER\" --install --game-path \"$GAME_PATH\"" || :

# Add Mods & Scripts.
COPY ["mods/", "$GAME_PATH/Mods/"]
COPY scripts/ /opt/

RUN chmod +x $GAME_PATH/StardewValley && \
    chmod -R 777 $GAME_PATH && \
    chown -R 1000:1000 /data/Stardew && \
    chmod +x /opt/*.sh

RUN mkdir /etc/services.d/utils && touch /etc/services.d/app/utils.dep
COPY run /etc/services.d/utils/run 
RUN chmod +x /etc/services.d/utils/run 

COPY start.sh $GAME_PATH/start.sh
RUN chmod +x $GAME_PATH/start.sh

# Embed the entrypoint script as /startapp.sh using a here-document.
RUN cat <<'EOF' > /startapp.sh
#!/bin/bash
export HOME=/config

# Loop through mod directories and configure them if enabled.
for modPath in $GAME_PATH/Mods/*/; do
    mod=$(basename "$modPath")
    # Normalize mod name: uppercase letters only (e.g., "Always On Server" becomes ENABLE_ALWAYSONSERVER_MOD)
    var="ENABLE_$(echo "${mod^^}" | tr -cd "[A-Z]")_MOD"
    if [ "${!var}" != "true" ]; then
        echo "Removing ${modPath} (${var}=${!var})"
        rm -rf "$modPath"
        continue
    fi
    if [ -f "${modPath}/config.json.template" ]; then
        echo "Configuring ${modPath}config.json"
        if [ "$(cat "${modPath}/config.json" 2> /dev/null)" == "" ]; then
            envsubst < "${modPath}/config.json.template" > "${modPath}/config.json"
        fi
    fi
done

# Run extra steps for certain mods.
 /opt/configure-remotecontrol-mod.sh
 /opt/tail-smapi-log.sh &

# Set XAUTHORITY and adjust the launch command.
export XAUTHORITY=~/.Xauthority
sed -i 's/env TERM=xterm $LAUNCHER "$@"/env SHELL=\/bin\/bash TERM=xterm xterm -e "\/bin\/bash -c $LAUNCHER \"$@\""/' $GAME_PATH/Stardew\ Valley

# Launch the game start script.
bash -c "$GAME_PATH/start.sh"

# Keep the container running.
sleep 233333333333333
EOF

RUN chmod +x /startapp.sh

# Debug: Verify that /startapp.sh exists.
RUN ls -la /startapp.sh
