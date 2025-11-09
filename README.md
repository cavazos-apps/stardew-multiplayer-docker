# Stardew Valley Multiplayer Docker Compose

This project aims to autostart a Stardew Valley Multiplayer Server as easy as possible.

## Notes

- Previous versions provided game files to create the server with the Docker container. To respect ConcernedApe's work and follow
intellectual property law, this will no longer be the case. Users will now be required to use their own copy of the game.
- Although I'm trying to put out updates, I don't have the time for testing thoroughly, so if you find issues, please put 
in an issue request and I will try to help.
- Thanks printfuck for the base code.

## Version Information

- **Stardew Valley**: Compatible with version 1.6.15 (latest patch)
- **SMAPI**: Version 4.3.2
- Both Steam and GOG versions are supported

## Custom Mods and Save Files

This Docker setup now supports easy management of custom mods and save files through host directory mappings:

### Save Files
Your game saves are automatically stored in `./valley_saves` on your host machine. This allows you to:
- Backup your saves easily
- Transfer saves between different servers
- Edit saves directly on your host

### Custom Mods
You can add your own SMAPI mods by creating a `custom_mods` directory:

1. Create a `custom_mods` directory in the project root (or copy from `custom_mods_example`)
2. Place each mod in its own subdirectory within `custom_mods/`
3. Restart the container to load the new mods

Example structure:
```
custom_mods/
├── YourModName1/
│   ├── manifest.json
│   └── YourModName1.dll
└── YourModName2/
    ├── manifest.json
    └── YourModName2.dll
```

See `custom_mods_example/README.md` for detailed instructions.

### Full Data Access (Optional)
If you need complete control over the Stardew Valley installation, you can uncomment the following line in your docker-compose file:
```yaml
# - ./stardew_data:/data/Stardew
```

This gives you full access to game files, all mods, and configurations from your host machine.

<a href="https://www.buymeacoffee.com/huntercavazos" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>


## Setup

### Steam

The Steam version now supports two deployment modes:

#### Runtime Authentication (Recommended for Kubernetes/Production)

The image can be built without Steam credentials, and the game will be downloaded at container startup. This is ideal for Kubernetes deployments where you want to store credentials in secrets.

```bash
# Build the image (no credentials needed)
docker compose -f docker-compose-steam.yml build

# Set credentials as environment variables for runtime
export STEAM_USER=<steamUsername>
export STEAM_PASS=<steamPassword>
export STEAM_GUARD=<latestSteamGuardCode> # Optional if Steam Guard is disabled

# Start the container (game downloads on first start)
docker compose -f docker-compose-steam.yml up
```

**Important**: The game files are downloaded to `./stardew_game` volume on first start. This directory will be reused on subsequent starts to avoid re-downloading.

For Kubernetes deployment instructions, see [KUBERNETES.md](KUBERNETES.md).

#### Build-time Authentication (Legacy)

You can still use the old method if preferred. See the git history for previous documentation.

#### Steam Guard

If your account is protected by Steam Guard and you cannot disable it, you need to provide a current Steam Guard code via the `STEAM_GUARD` environment variable.

**Note**: Disabling Steam Guard on a dedicated server account is recommended for automated deployments.
### GOG

To my knowledge there is no way to automate this. To use game files from GOG, you will need to download the Linux installer. 
Sign in, go to Games, find Stardew, change the system to Linux, and download the game installer. The file will look something 
like `stardew_valley_x.x.x.xxx.sh`. Unzip this file (using Git Bash if you are on Windows), and copy the files within the 
`data/noarch/` directory to `docker/game_data/`. Start the container using `docker compose -f docker-compose-gog.yml up`. To 
rebuild the container after updating the files, use `docker compose -f docker-compose-gog.yml build --no-cache`.

### Configuration

Edit the docker-compose.yml with your desired configuration settings. Setting values are quite descriptive as to what
they set.

```
environment:
      # VNC
      - VNC_PASSWORD=insecure
      - DISPLAY_HEIGHT=900
      - DISPLAY_WIDTH=1200
      
      # Always On Server mod
      ## Removing this will probably defeat the point of ever using this?
      - ENABLE_ALWAYSONSERVER_MOD=${ENABLE_ALWAYSONSERVER_MOD-true}
      - ALWAYS_ON_SERVER_HOTKEY=${ALWAYS_ON_SERVER_HOTKEY-F9}
      - ALWAYS_ON_SERVER_PROFIT_MARGIN=${ALWAYS_ON_SERVER_PROFIT_MARGIN-100}
      - ALWAYS_ON_SERVER_UPGRADE_HOUSE=${ALWAYS_ON_SERVER_UPGRADE_HOUSE-0}
      - ALWAYS_ON_SERVER_PET_NAME=${ALWAYS_ON_SERVER_PET_NAME-Rufus}
      - ALWAYS_ON_SERVER_FARM_CAVE_CHOICE_MUSHROOMS=${ALWAYS_ON_SERVER_FARM_CAVE_CHOICE_MUSHROOMS-true}
      - ALWAYS_ON_SERVER_COMMUNITY_CENTER_RUN=${ALWAYS_ON_SERVER_COMMUNITY_CENTER_RUN-true}
      - ALWAYS_ON_SERVER_TIME_OF_DAY_TO_SLEEP=${ALWAYS_ON_SERVER_TIME_OF_DAY_TO_SLEEP-2200}
      - ALWAYS_ON_SERVER_LOCK_PLAYER_CHESTS=${ALWAYS_ON_SERVER_LOCK_PLAYER_CHESTS-false}
      - ALWAYS_ON_SERVER_CLIENTS_CAN_PAUSE=${ALWAYS_ON_SERVER_CLIENTS_CAN_PAUSE-true}
      - ALWAYS_ON_SERVER_COPY_INVITE_CODE_TO_CLIPBOARD=${ALWAYS_ON_SERVER_COPY_INVITE_CODE_TO_CLIPBOARD-false}

      - ALWAYS_ON_SERVER_FESTIVALS_ON=${ALWAYS_ON_SERVER_FESTIVALS_ON-true}
      - ALWAYS_ON_SERVER_EGG_HUNT_COUNT_DOWN=${ALWAYS_ON_SERVER_EGG_HUNT_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_FLOWER_DANCE_COUNT_DOWN=${ALWAYS_ON_SERVER_FLOWER_DANCE_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_LUAU_SOUP_COUNT_DOWN=${ALWAYS_ON_SERVER_LUAU_SOUP_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_JELLY_DANCE_COUNT_DOWN=${ALWAYS_ON_SERVER_JELLY_DANCE_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_GRANGE_DISPLAY_COUNT_DOWN=${ALWAYS_ON_SERVER_GRANGE_DISPLAY_COUNT_DOWN-600}
      - ALWAYS_ON_SERVER_ICE_FISHING_COUNT_DOWN=${ALWAYS_ON_SERVER_ICE_FISHING_COUNT_DOWN-600}

      - ALWAYS_ON_SERVER_END_OF_DAY_TIMEOUT=${ALWAYS_ON_SERVER_END_OF_DAY_TIMEOUT-300}
      - ALWAYS_ON_SERVER_FAIR_TIMEOUT=${ALWAYS_ON_SERVER_FAIR_TIMEOUT-1200}
      - ALWAYS_ON_SERVER_SPIRITS_EVE_TIMEOUT=${ALWAYS_ON_SERVER_SPIRITS_EVE_TIMEOUT-900}
      - ALWAYS_ON_SERVER_WINTER_STAR_TIMEOUT=${ALWAYS_ON_SERVER_WINTER_STAR_TIMEOUT-900}

      - ALWAYS_ON_SERVER_EGG_FESTIVAL_TIMEOUT=${ALWAYS_ON_SERVER_EGG_FESTIVAL_TIMEOUT-120}
      - ALWAYS_ON_SERVER_FLOWER_DANCE_TIMEOUT=${ALWAYS_ON_SERVER_FLOWER_DANCE_TIMEOUT-120}
      - ALWAYS_ON_SERVER_LUAU_TIMEOUT=${ALWAYS_ON_SERVER_LUAU_TIMEOUT-120}
      - ALWAYS_ON_SERVER_DANCE_OF_JELLIES_TIMEOUT=${ALWAYS_ON_SERVER_DANCE_OF_JELLIES_TIMEOUT-120}
      - ALWAYS_ON_SERVER_FESTIVAL_OF_ICE_TIMEOUT=${ALWAYS_ON_SERVER_FESTIVAL_OF_ICE_TIMEOUT-120 }

      # Auto Load Game mod
      ## Removing this will mean you need to VNC in to manually start the game each boot
      - ENABLE_AUTOLOADGAME_MOD=${ENABLE_AUTOLOADGAME-null}
      - AUTO_LOAD_GAME_LAST_FILE_LOADED=${AUTO_LOAD_GAME_LAST_FILE_LOADED-null}
      - AUTO_LOAD_GAME_FORGET_LAST_FILE_ON_TITLE=${AUTO_LOAD_GAME_FORGET_LAST_FILE_ON_TITLE-true}
      - AUTO_LOAD_GAME_LOAD_INTO_MULTIPLAYER=${AUTO_LOAD_GAME_LOAD_INTO_MULTIPLAYER-true}
      
      # Unlimited Players Mod
      - ENABLE_UNLIMITEDPLAYERS_MOD=${ENABLE_UNLIMITEDPLAYERS-true}
      - UNLIMITED_PLAYERS_PLAYER_LIMIT=${UNLIMITED_PLAYERS_PLAYER_LIMIT-8}

      # Chat Commands mod
      - ENABLE_CHATCOMMANDS_MOD=${ENABLE_CHATCOMMANDS_MOD-false}

      # Console Commands mod
      - ENABLE_CONSOLECOMMANDS_MOD=${ENABLE_CONSOLECOMMANDS_MOD-false}

      # Time Speed mod
      - ENABLE_TIMESPEED_MOD=${ENABLE_TIMESPEED_MOD-false}

      ## Days are only 20 hours long
      ##   7.0 = 14 mins per in game day (default)
      ##  10.0 = 20 mins
      ##  15.0 = 30 mins
      ##  20.0 = 40 mins
      ##  30.0 = 1 hour
      ## 120.0 = 4 hours
      ## 300.0 = 10 hours
      ## 600.0 = 20 hours (realtime)

      - TIME_SPEED_DEFAULT_TICK_LENGTH=${TIME_SPEED_DEFAULT_TICK_LENGTH-7.0}
      - TIME_SPEED_TICK_LENGTH_BY_LOCATION_INDOORS=${TIME_SPEED_TICK_LENGTH_BY_LOCATION_INDOORS-7.0}
      - TIME_SPEED_TICK_LENGTH_BY_LOCATION_OUTDOORS=${TIME_SPEED_TICK_LENGTH_BY_LOCATION_OUTDOORS-7.0}
      - TIME_SPEED_TICK_LENGTH_BY_LOCATION_MINE=${TIME_SPEED_TICK_LENGTH_BY_LOCATION_MINE-7.0}

      - TIME_SPEED_ENABLE_ON_FESTIVAL_DAYS=${TIME_SPEED_ENABLE_ON_FESTIVAL_DAYS-false}
      - TIME_SPEED_FREEZE_TIME_AT=${TIME_SPEED_FREEZE_TIME_AT-null}
      - TIME_SPEED_LOCATION_NOTIFY=${TIME_SPEED_LOCATION_NOTIFY-false}

      - TIME_SPEED_KEYS_FREEZE_TIME=${TIME_SPEED_KEYS_FREEZE_TIME-N}
      - TIME_SPEED_KEYS_INCREASE_TICK_INTERVAL=${TIME_SPEED_KEYS_INCREASE_TICK_INTERVAL-OemPeriod}
      - TIME_SPEED_KEYS_DECREASE_TICK_INTERVAL=${TIME_SPEED_KEYS_DECREASE_TICK_INTERVAL-OemComma}
      - TIME_SPEED_KEYS_RELOAD_CONFIG=${TIME_SPEED_KEYS_RELOAD_CONFIG-B}

      # Crops Anytime Anywhere mod
      - ENABLE_CROPSANYTIMEANYWHERE_MOD=${ENABLE_CROPSANYTIMEANYWHERE_MOD-false}

      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SPRING=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SPRING-true}
      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SUMMER=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_SUMMER-true}
      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_FALL=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_FALL-true}
      - CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_WINTER=${CROPS_ANYTIME_ANYWHERE_ENABLE_IN_SEASONS_WINTER-true}

      - CROPS_ANYTIME_ANYWHERE_FARM_ANY_LOCATION=${CROPS_ANYTIME_ANYWHERE_FARM_ANY_LOCATION-true}

      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_DIRT=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_DIRT-true}
      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_GRASS=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_GRASS-true}
      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_STONE=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_STONE-false}
      - CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_OTHER=${CROPS_ANYTIME_ANYWHERE_FORCE_TILLABLE_OTHER-false}

      # Friends Forever mod
      - ENABLE_FRIENDSFOREVER_MOD=${ENABLE_FRIENDSFOREVER_MOD-false}

      - FRIENDS_FOREVER_AFFECT_SPOUSE=${FRIENDS_FOREVER_AFFECT_SPOUSE-false}
      - FRIENDS_FOREVER_AFFECT_DATES=${FRIENDS_FOREVER_AFFECT_DATES-true}
      - FRIENDS_FOREVER_AFFECT_EVERYONE_ELSE=${FRIENDS_FOREVER_AFFECT_EVERYONE_ELSE-true}
      - FRIENDS_FOREVER_AFFECT_ANIMALS=${FRIENDS_FOREVER_AFFECT_ANIMALS-true}

      # No Fence Decay mod
      - ENABLE_NOFENCEDECAY_MOD=${ENABLE_NOFENCEDECAY_MOD-false}

      # Non-destructive NPCs mod
      - ENABLE_NONDESTRUCTIVENPCS_MOD=${ENABLE_NONDESTRUCTIVENPCS_MOD-false}
```

## Game Setup

Initially, you have to create or load a game once via VNC or web interface. After that, the Autoload Mod jumps into the
previously loaded game save everytime you restart or rebuild the container. The AutoLoad Mod config file is by default
mounted as a volume, since it keeps the state of the ongoing game save, but you can also copy your existing game save to
the `Saves` volume and define the game save's name in the environment variables. Once started, press the Always On
Hotkey (default F9) to enter server mode.

### VNC

Use a VNC client like `TightVNC` on Windows or plain `vncviewer` on any Linux distribution to connect to the server. You
can modify the VNC Port and IP address and Password in the `docker-compose.yml` file like this:

Localhost:

```
   # Server is only reachable on localhost on port 5902...
   ports:
     - 127.0.0.1:5902:5900
   # ... with the password "insecure"
   environment:
     - VNCPASS=insecure
```

### Web Interface

On port 5800 (mapped to 5801 by default) inside the container is a web interface. This is a bit easier and more
accessible than just the VNC interface. Although you will be asked for the vnc password, I wouldn't recommend exposing
the port to the outside world.

![img](https://store.eris.cc/uploads/859865e1ab5b23fb223923d9a7e4806b.PNG)

## Accessing the server

- Direct IP: You will need to set a up direct IP access over the internet "Join LAN Game" by opening (or forwarding)
  port 24642. Feel free to change this mapping in the compose file. People can then "Join LAN Game" via your external IP.

(Taken from mod description. See [Always On Server](https://www.nexusmods.com/stardewvalley/mods/2677?tab=description)
for more info.)

## Mods

- [Always On Server](https://www.nexusmods.com/stardewvalley/mods/2677) (Default: Required)
- [Auto Load Game](https://www.nexusmods.com/stardewvalley/mods/2509) (Default: On)
- [Crops Anytime Anywhere](https://www.nexusmods.com/stardewvalley/mods/3000) (Default: Off)
- [Friends Forever](https://www.nexusmods.com/stardewvalley/mods/1738) (Default: Off)
- [No Fence Decay](https://www.nexusmods.com/stardewvalley/mods/1180) (Default: Off)
- [Non Destructive NPCs](https://www.nexusmods.com/stardewvalley/mods/5176) (Default: Off)
- [Remote Control](https://github.com/Novex/stardew-remote-control) (Default: On)
- [TimeSpeed](https://www.nexusmods.com/stardewvalley/mods/169) (Default: Off)
- [Unlimited Players](https://www.nexusmods.com/stardewvalley/mods/2213) (Default: On)

## Troubleshooting

### Waiting for Day to End

Check VNC just to make sure the host hasn't gotten stuck on a prompt.

### Error Messages in Console

Usually you should be able to ignore any message there. If the game doesn't start or any errors appear, you should look
for messages like "cannot open display", which would most likely indicate permission errors.

### VNC

Access the game via VNC to initially load or start a pre-generated game save. You can control the server from there or
edit the config.json files in the configs folder.
