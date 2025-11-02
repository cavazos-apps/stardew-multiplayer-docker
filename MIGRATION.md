# Migration Guide - Volume Mappings Update

This document explains the new volume mapping features added to the Stardew Valley Multiplayer Docker setup.

## What's New

### 1. Updated SMAPI Version
- **SMAPI 4.1.10** is now installed on both Steam and GOG versions
- Compatible with **Stardew Valley 1.6.15** (latest patch)

### 2. Custom Mods Support
You can now add your own SMAPI mods without rebuilding the Docker image!

**How to use:**
1. Create a `custom_mods` directory in the project root
2. Add your mods following the structure in `custom_mods_example/README.md`
3. Restart the container to load new mods

**Example:**
```
custom_mods/
├── YourMod1/
│   ├── manifest.json
│   └── YourMod1.dll
└── YourMod2/
    ├── manifest.json
    └── YourMod2.dll
```

### 3. Save Files Access
- Save files are stored in `./valley_saves` on your host machine (unchanged from previous versions)
- Easy to backup, transfer, or edit

### 4. Full Data Access (Optional)
For advanced users who need complete control over the Stardew Valley installation:

Uncomment this line in your `docker-compose.yml`:
```yaml
- ./stardew_data:/data/Stardew
```

This provides full access to:
- Game files
- All mods (built-in and custom)
- SMAPI installation
- All configurations

## Volume Mappings Summary

| Host Directory | Container Path | Purpose |
|----------------|----------------|---------|
| `./valley_saves` | `/config/xdg/config/StardewValley/Saves` | Game save files |
| `./configs/autoload.json` | `/data/Stardew/game/Mods/AutoLoadGame/config.json` | AutoLoad mod config |
| `./custom_mods` | `/data/Stardew/game/Mods/CustomMods` | Your custom SMAPI mods |
| `./stardew_data` (optional) | `/data/Stardew` | Complete game installation |

## Compatibility Notes

- All custom mods must be compatible with SMAPI 4.1.10 and Stardew Valley 1.6.15
- The built-in mods remain available and can still be enabled/disabled via environment variables
- Custom mods in `./custom_mods` will load alongside the built-in mods

## Built-in Mods (Unchanged)

These mods are still included and can be enabled/disabled via environment variables:
- Always On Server
- Auto Load Game
- Crops Anytime Anywhere
- Friends Forever
- No Fence Decay
- Non Destructive NPCs
- Remote Control
- Time Speed
- Unlimited Players
- Chat Commands
- Console Commands

## Troubleshooting

### Custom mods not loading?
1. Check the SMAPI log via VNC or container logs
2. Verify the mod's `manifest.json` specifies a compatible SMAPI version
3. Ensure the mod directory structure is correct (each mod in its own folder)

### Need to access SMAPI logs?
The logs are available at:
- Inside container: `/config/xdg/config/StardewValley/ErrorLogs/`
- Or view them via the VNC interface

### Want to reset to defaults?
Simply remove the volume mappings from your docker-compose file and rebuild the container.

## Questions or Issues?

Please open an issue on GitHub if you encounter any problems with the new volume mappings or SMAPI version.
