# Directory Structure Overview

This document provides a visual overview of how the host directories map to container paths.

## Complete Directory Structure

```
stardew-multiplayer-docker/          # Project root on host
├── docker/
│   ├── Dockerfile-steam              # SMAPI 4.1.10 ✓
│   ├── Dockerfile-gog                # SMAPI 4.1.10 ✓
│   ├── Dockerfile                    # SMAPI 4.1.10 ✓
│   └── mods/                         # Built-in mods (baked into image)
│       ├── Always On Server/
│       ├── AutoLoadGame/
│       ├── UnlimitedPlayers/
│       └── ... (other built-in mods)
├── configs/
│   └── autoload.json                 # AutoLoad mod config → mounted to container
├── valley_saves/                     # Your save files (host directory)
│   ├── YourFarm_123456/
│   └── AnotherFarm_789012/
├── custom_mods/                      # Your custom mods (host directory)
│   ├── CustomMod1/
│   │   ├── manifest.json
│   │   └── CustomMod1.dll
│   └── CustomMod2/
│       ├── manifest.json
│       └── CustomMod2.dll
├── stardew_data/                     # Optional: Full game data (if uncommented)
│   └── Stardew/
│       └── game/
│           ├── StardewValley         # Game executable
│           ├── Mods/                 # All mods
│           └── ... (other game files)
├── docker-compose-steam.yml          # Updated with volume mappings ✓
├── docker-compose-gog.yml            # Updated with volume mappings ✓
├── README.md                         # Updated documentation ✓
├── MIGRATION.md                      # Migration guide ✓
└── custom_mods_example/              # Example directory structure
    └── README.md                     # Custom mods instructions ✓
```

## Volume Mappings Explained

### Default Mappings (Always Active)

```
Host Path                    Container Path                                     Purpose
──────────────────────────────────────────────────────────────────────────────────────────────
./valley_saves          →    /config/xdg/config/StardewValley/Saves          Game saves
./configs/autoload.json →    /data/Stardew/game/Mods/AutoLoadGame/config.json  AutoLoad config
./custom_mods           →    /data/Stardew/game/Mods/CustomMods              Custom SMAPI mods
```

### Optional Mapping (Commented Out)

```
Host Path                    Container Path                  Purpose
────────────────────────────────────────────────────────────────────────────────
./stardew_data          →    /data/Stardew                  Full game installation
```

## Container Internal Structure

Inside the container at `/data/Stardew/game/Mods/`:

```
/data/Stardew/game/Mods/
├── Always On Server/           # Built-in mod (from Docker image)
├── AutoLoadGame/               # Built-in mod (config mounted from host)
├── UnlimitedPlayers/           # Built-in mod (from Docker image)
├── ... (other built-in mods)
└── CustomMods/                 # ← YOUR CUSTOM MODS (mounted from host)
    ├── YourCustomMod1/
    └── YourCustomMod2/
```

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                          Host Machine                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  custom_mods/              valley_saves/       stardew_data/   │
│  └── YourMod1/             └── YourFarm/       (optional)      │
│                                                                 │
└────────────┬─────────────────┬─────────────────┬───────────────┘
             │                 │                 │
             │ Volume Mount    │ Volume Mount    │ Volume Mount
             │                 │                 │
┌────────────▼─────────────────▼─────────────────▼───────────────┐
│                      Docker Container                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  /data/Stardew/game/Mods/    /config/.../Saves   /data/Stardew │
│  ├── Built-in Mods           └── YourFarm/       (all files)   │
│  └── CustomMods/                                                │
│      └── YourMod1/ ← from host                                  │
│                                                                 │
│  ┌──────────────────────────────────────────────┐              │
│  │    Stardew Valley + SMAPI 4.1.10             │              │
│  │    Compatible with SV 1.6.15                 │              │
│  └──────────────────────────────────────────────┘              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Usage Examples

### Example 1: Add a Custom Mod

1. Download a mod compatible with SMAPI 4.1.10
2. Create `custom_mods/` directory in project root
3. Extract mod to `custom_mods/ModName/`
4. Restart container
5. Mod loads automatically!

### Example 2: Backup Your Saves

```bash
# Your saves are already on the host!
tar -czf saves-backup-$(date +%Y%m%d).tar.gz valley_saves/
```

### Example 3: Full Access Mode

Uncomment in docker-compose.yml:
```yaml
volumes:
  - ./stardew_data:/data/Stardew
```

Now you can:
- Edit game files directly
- Modify SMAPI installation
- Access all built-in mod configs
- Completely customize the installation

## Benefits of This Structure

✅ **No Rebuilds Required** - Add/remove mods without rebuilding Docker image
✅ **Easy Backups** - All important data is on the host
✅ **Portable** - Copy directories to move your setup
✅ **Flexible** - Choose between simple (custom_mods) or full control (stardew_data)
✅ **Persistent** - Data survives container deletion/recreation
✅ **Collaborative** - Share mod packs by sharing custom_mods directory

## Troubleshooting

### Can't find custom_mods directory in container?
- Make sure you created it on the host first
- Docker creates empty directory if host directory doesn't exist
- Check volume mapping in docker-compose.yml

### Mods not loading?
- Check SMAPI log: `/config/xdg/config/StardewValley/ErrorLogs/`
- Verify mod structure: each mod in its own subdirectory
- Ensure mod compatibility with SMAPI 4.1.10

### Want to reset everything?
```bash
# Stop container
docker compose down

# Remove host directories (WARNING: deletes your data!)
rm -rf custom_mods valley_saves stardew_data

# Rebuild and start fresh
docker compose build --no-cache
docker compose up
```
