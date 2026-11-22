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

## Building

Complete, reproducible build instructions are in the root
[BUILD.md](../BUILD.md). That document lists all required dependency
versions, the full twelve-entry `UndertaleModCli replace` command, hash
verification, `Mod Files` layout, README.txt generation and Inno Setup
compilation.

This folder intentionally does not duplicate those instructions, so there
is only one authoritative build procedure.

The repository does not contain the original or modified `data.win` as a standalone file.
Build against your own legally obtained copy of the supported game. The
compiled installer is available as `Installer/Setup.exe` and in Releases.
