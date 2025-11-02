# Custom Mods Directory

This is an example directory structure for adding your own SMAPI mods to the Stardew Valley server.

## How to Use

1. **Rename this directory**: Copy or rename `custom_mods_example` to `custom_mods` in the project root.

2. **Add your mods**: Place each SMAPI mod in its own subdirectory within `custom_mods/`:
   ```
   custom_mods/
   ├── YourModName1/
   │   ├── manifest.json
   │   ├── YourModName1.dll
   │   └── config.json (optional)
   ├── YourModName2/
   │   ├── manifest.json
   │   └── YourModName2.dll
   └── ...
   ```

3. **Start the server**: The mods in this directory will be automatically loaded when the container starts.

## Important Notes

- Each mod should be in its own subdirectory
- Make sure mods are compatible with SMAPI 4.1.10 and Stardew Valley 1.6.15
- The `custom_mods` directory is git-ignored, so your mods won't be committed to the repository
- Mods placed here are in addition to the built-in mods that come with this Docker image

## Example Mod Structure

Here's an example of what a mod directory looks like:

```
custom_mods/
└── ExampleMod/
    ├── manifest.json       # Required: Mod metadata
    ├── ExampleMod.dll      # Required: The compiled mod
    ├── config.json         # Optional: Mod configuration
    ├── assets/             # Optional: Mod assets (images, etc.)
    └── i18n/               # Optional: Translations
```

## Finding Mods

You can find SMAPI-compatible mods at:
- [Nexus Mods](https://www.nexusmods.com/stardewvalley/mods/)
- [ModDrop](https://www.moddrop.com/stardew-valley)
- Make sure to download mods that are compatible with the current game version

## Troubleshooting

- Check the SMAPI log via VNC or logs to see if mods loaded correctly
- Verify that the mod is compatible with SMAPI 4.1.10
- Ensure the manifest.json file is valid JSON
- Some mods may require additional dependencies
