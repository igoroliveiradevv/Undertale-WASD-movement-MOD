# Mod source

This folder contains the GameMaker Language (GML) code entries that were
modified to add the WASD control scheme, plus the player-facing mod readme.

These files were exported from `data.win` with UndertaleModTool and edited.
They are provided for transparency and for rebuilding the mod against a
matching Undertale version.

## Modified code entries

| File | Purpose |
|---|---|
| `gml_Object_obj_time_Step_1.gml` | Loads `[General] cs`, scheme-aware direction input, dispatches arrow events to battle/heart objects |
| `gml_Object_obj_time_Create_0.gml` | Defaults `global.control_scheme` |
| `gml_Object_obj_settingsmenu_Draw_0.gml` | Adds CONTROL SCHEME row and menu handling |
| `gml_Object_obj_settingsmenu_Step_0.gml` | Saves `cs` to `config.ini` |
| `gml_Object_obj_joypadmenu_Draw_0.gml` | WASD menu navigation |
| `gml_Object_obj_heart_Step_0.gml` | Red SOUL platforming release checks |
| `gml_Object_obj_heart_sansbattle_Step_0.gml` | sans battle SOUL checks |
| `gml_Object_obj_purpleheart_Step_0.gml` | Purple SOUL vertical movement |
| `gml_Object_obj_shootguy_Step_0.gml` | Shootguy directional input |
| `gml_Object_obj_asgore_spearswipe_Step_2.gml` | Asgore spear-swipe direction check |
| `gml_Script_textdata_en.gml` | English strings |
| `gml_Script_textdata_ja.gml` | Japanese strings |

## Rebuild requirements

- Undertale Steam PC `data.win`, original SHA-256:
  `b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7`
- UndertaleModTool 0.9.2.0 CLI (`UndertaleModCli.exe`)
- Inno Setup 6.7.x to compile the installer

The repository does **not** include the original or modified `data.win`.
The compiled installer is provided as a release asset.

## Rebuild outline

1. Replace the listed code entries with `UndertaleModCli replace`, for example:

   ```powershell
   UndertaleModCli.exe replace data.win `
     -c "gml_Object_obj_time_Step_1=Source\Modified GML\gml_Object_obj_time_Step_1.gml" `
     -c "gml_Object_obj_settingsmenu_Draw_0=Source\Modified GML\gml_Object_obj_settingsmenu_Draw_0.gml" `
     ... `
     -o "Mod Files\data.win"
   ```

2. Compute the new modded `data.win` SHA-256.
3. Update `ORIGINAL_SHA256`, `MOD_SHA256`, `ORIGINAL_SIZE` and `MOD_SIZE`
   in `Installer/Installer_Source/installer.iss`.
4. Compile `Installer/Installer_Source/installer.iss` with Inno Setup.
5. Test install, launch, and uninstall before publishing.
