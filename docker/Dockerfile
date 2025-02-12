# Pull base image.
FROM jlesage/baseimage-gui:debian-11

# Set the environment variable for the start script location.
ENV APP_START_SCRIPT=/startapp.sh
ENV APP_NAME="StardewValley"
ENV GAME_PATH="/data/Stardew/game"

# Install dependencies.
RUN apt-get update && apt-get install -y \
      wget unzip tar strace mono-complete xterm gettext-base jq netcat procps lib32gcc-s1 locales \
    && apt-get clean

# Create required directories.
RUN mkdir -p ${GAME_PATH} && mkdir -p /data/nexus && mkdir -p /data/steamcmd

## (Other build steps omitted for brevity – assume they run as intended.)

# Copy necessary files.
COPY ["mods/", "$GAME_PATH/Mods/"]
COPY scripts/ /opt/
COPY start.sh $GAME_PATH/start.sh
RUN chmod +x $GAME_PATH/start.sh

# Embed the entrypoint script directly into /startapp.sh using a here-document.
RUN cat <<'EOF' > /startapp.sh
#!/bin/bash
export HOME=/config

# Loop through mod directories and configure them.
for modPath in $GAME_PATH/Mods/*/; do
    mod=$(basename "$modPath")
    var="ENABLE_$(echo "${mod^^}" | tr -cd "[A-Z]")_MOD"
    if [ "${!var}" != "true" ]; then
        echo "Removing ${modPath} (${var}=${!var})"
        rm -rf "$modPath"
        continue
    fi
    if [ -f "${modPath}/config.json.template" ]; then
        echo "Configuring ${modPath}config.json"
        if [ "$(cat "${modPath}/config.json" 2>/dev/null)" == "" ]; then
            envsubst < "${modPath}/config.json.template" > "${modPath}/config.json"
        fi
    fi
done

# Execute extra mod-specific configuration.
 /opt/configure-remotecontrol-mod.sh
 /opt/tail-smapi-log.sh &

# Set XAUTHORITY and adjust the launch command.
export XAUTHORITY=~/.Xauthority
sed -i 's/env TERM=xterm $LAUNCHER "$@"/env SHELL=\/bin\/bash TERM=xterm xterm -e "\/bin\/bash -c $LAUNCHER \"$@\""/' "$GAME_PATH/Stardew Valley"

# Launch the start script.
bash -c "$GAME_PATH/start.sh"

# Prevent container exit.
sleep 233333333333333
EOF

RUN chmod +x /startapp.sh

# Debug: verify that the file exists in the image.
RUN ls -la /startapp.sh
