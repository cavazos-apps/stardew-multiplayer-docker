#!/bin/bash
export HOME=/config

# Initialize Steam game download if needed
echo "Running Steam initialization..."
/opt/steam-init.sh

for modPath in $GAME_PATH/Mods/*/
do
  mod=$(basename "$modPath")

  # Normalize mod name ot uppercase and only characters, eg. "Always On Server" => ENABLE_ALWAYSONSERVER_MOD
  var="ENABLE_$(echo "${mod^^}" | tr -cd '[A-Z]')_MOD"

  # Remove the mod if it's not enabled
  if [ "${!var}" != "true" ]; then
    echo "Removing ${modPath} (${var}=${!var})"
    rm -rf "$modPath"
    continue
  fi

  if [ -f "${modPath}/config.json.template" ]; then
    echo "Configuring ${modPath}config.json"

    # Seed the config.json only if one isn't manually mounted in (or is empty)
    if [ "$(cat "${modPath}config.json" 2> /dev/null)" == "" ]; then
      envsubst < "${modPath}config.json.template" > "${modPath}config.json"
    fi
  fi
done

# Run extra steps for certain mods
/opt/configure-remotecontrol-mod.sh

/opt/tail-smapi-log.sh &

# Ready to start!

export XAUTHORITY=~/.Xauthority
sed -i 's/env TERM=xterm $LAUNCHER "$@"/env SHELL=\/bin\/bash TERM=xterm xterm  -e "\/bin\/bash -c $LAUNCHER \"$@\""/' $GAME_PATH/Stardew\ Valley

bash -c "$GAME_PATH/start.sh"

sleep 233333333333333
