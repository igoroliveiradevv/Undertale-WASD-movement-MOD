# Building Undertale WASD Controls Mod from source

This document describes how to reproduce the mod and the installer from a
legitimate copy of UNDERTALE. It is written for Windows and PowerShell.

The repository contains source code only. It does **not** contain the
original or modified `data.win`. You must supply your own legally obtained
copy of the supported game.

## 1. Requirements

| Component | Version used and tested | Notes |
|---|---|---|
| Windows | Windows 10/11, 64-bit | Build scripts are PowerShell |
| UNDERTALE | Steam PC release, 32-bit GameMaker: Studio 1.4 build | `data.win` bytecode version 16 |
| UndertaleModTool CLI | **0.9.2.0** | `UndertaleModCli.exe` |
| Inno Setup | **6.7.3** | Provides `ISCC.exe` |
| PowerShell | 5.1 or newer | Commands below use PowerShell syntax |

Optional:

- Git, to clone the repository.
- A text editor with UTF-8 support for the GML files.

Pinned download locations:

- UndertaleModTool 0.9.2.0 release assets:
  `https://github.com/UnderminersTeam/UndertaleModTool/releases/tag/0.9.2.0`
  Download `UTMT_CLI_v0.9.2.0-Windows.zip`, not the GUI build.
- Inno Setup:
  `https://jrsoftware.org/isdl.php` (6.7.3 at the time of writing).

Extract the CLI somewhere outside the repository, for example:

```powershell
C:\Tools\UTMT_CLI\UndertaleModCli.exe
```

The CLI, Inno Setup, the game, and generated `data.win` files must not be
committed to the repository.

## 2. Supported original game file

This mod build targets the Steam PC release whose original `data.win` is:

- Size: `62921978` bytes
- SHA-256:
  `b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7`

The official modded file produced by the documented steps is:

- Size: `62927354` bytes
- SHA-256:
  `9b13774bd7ebeed1929885b8efa8a906f40b2a9931467e811a6bfc8239899f39`

If your original `data.win` does not match the original hash, the game is a
different version or has already been modified. The installer intentionally
rejects such files. Do not publish a build made from an unsupported version
unless you have tested it and updated every version constant.

## 3. Obtain the original data.win legitimately

1. Install UNDERTALE through Steam.
2. In Steam, right-click **UNDERTALE** > **Manage** > **Browse local files**.
3. Copy `data.win` from that folder to a build folder, for example:

   ```powershell
   New-Item -ItemType Directory -Force "C:\Build\undertale-original" | Out-Null
   Copy-Item "D:\SteamLibrary\steamapps\common\Undertale\data.win" `
             "C:\Build\undertale-original\data.win"
   ```

4. Verify the hash:

   ```powershell
   Get-FileHash -Algorithm SHA256 -LiteralPath "C:\Build\undertale-original\data.win"
   ```

   The hash must be:
   `B718F8223A5BB31979FFEED10BE6140C857B882FC0D0462B89D6287AE38C81C7`

5. Keep this original file read-only. The build always writes a new file;
   it never edits the original in place.

If Steam has updated the game, the hash will differ. In that case the
existing source may still compile, but the installer compatibility checks
and tested behavior no longer apply.

## 4. Expected repository layout

Clone or download the repository, then open PowerShell in the repository
root:

```text
Undertale-WASD-movement-MOD/
├── BUILD.md
├── README.md
├── CHANGELOG.md
├── TEST_RESULTS.md
├── Installer/
│   ├── Setup.exe
│   └── Installer_Source/
│       └── installer.iss
└── Source/
    ├── MOD_README.txt
    ├── README.md
    └── Modified GML/
        ├── gml_Object_obj_asgore_spearswipe_Step_2.gml
        ├── gml_Object_obj_heart_Step_0.gml
        ├── gml_Object_obj_heart_sansbattle_Step_0.gml
        ├── gml_Object_obj_joypadmenu_Draw_0.gml
        ├── gml_Object_obj_purpleheart_Step_0.gml
        ├── gml_Object_obj_settingsmenu_Draw_0.gml
        ├── gml_Object_obj_settingsmenu_Step_0.gml
        ├── gml_Object_obj_shootguy_Step_0.gml
        ├── gml_Object_obj_time_Create_0.gml
        ├── gml_Object_obj_time_Step_1.gml
        ├── gml_Script_textdata_en.gml
        └── gml_Script_textdata_ja.gml
```

`Installer/Installer_Source/installer.iss` expects this build layout,
relative to the repository root:

```text
<repository root>/
├── Mod Files/
│   ├── data.win          (generated in step 6; never commit)
│   └── README.txt        (copied from Source/MOD_README.txt in step 5)
├── Installer/
│   └── Installer_Source/
│       └── installer.iss
└── Source/
    └── Modified GML/
```

Create the `Mod Files` folder:

```powershell
New-Item -ItemType Directory -Force "Mod Files" | Out-Null
```

## 5. Create Mod Files\README.txt

The installer packages `Mod Files\README.txt` and installs it as
`WASD_MOD_README.txt`. The source of that player-facing readme is
`Source\MOD_README.txt`:

```powershell
Copy-Item -LiteralPath "Source\MOD_README.txt" `
          -Destination "Mod Files\README.txt" -Force
```

Edit `Source\MOD_README.txt` (not the copy) if the player-facing text needs
changes, then repeat the copy. `README.md` in the repository root is the
project/developer readme and is not packaged by the installer.

## 6. Rebuild the modified data.win

Run all commands from the repository root. Set the CLI path to your own
extracted UndertaleModTool CLI and the original file path to the copy made
in step 3:

```powershell
$cli      = "C:\Tools\UTMT_CLI\UndertaleModCli.exe"
$original = "C:\Build\undertale-original\data.win"

# Remove an older build output so the CLI writes a fresh file.
Remove-Item -LiteralPath "Mod Files\data.win" -Force -ErrorAction SilentlyContinue

& $cli replace $original `
  -c "gml_Object_obj_time_Step_1=Source\Modified GML\gml_Object_obj_time_Step_1.gml" `
  -c "gml_Object_obj_time_Create_0=Source\Modified GML\gml_Object_obj_time_Create_0.gml" `
  -c "gml_Object_obj_settingsmenu_Draw_0=Source\Modified GML\gml_Object_obj_settingsmenu_Draw_0.gml" `
  -c "gml_Object_obj_settingsmenu_Step_0=Source\Modified GML\gml_Object_obj_settingsmenu_Step_0.gml" `
  -c "gml_Object_obj_joypadmenu_Draw_0=Source\Modified GML\gml_Object_obj_joypadmenu_Draw_0.gml" `
  -c "gml_Object_obj_heart_Step_0=Source\Modified GML\gml_Object_obj_heart_Step_0.gml" `
  -c "gml_Object_obj_heart_sansbattle_Step_0=Source\Modified GML\gml_Object_obj_heart_sansbattle_Step_0.gml" `
  -c "gml_Object_obj_purpleheart_Step_0=Source\Modified GML\gml_Object_obj_purpleheart_Step_0.gml" `
  -c "gml_Object_obj_shootguy_Step_0=Source\Modified GML\gml_Object_obj_shootguy_Step_0.gml" `
  -c "gml_Object_obj_asgore_spearswipe_Step_2=Source\Modified GML\gml_Object_obj_asgore_spearswipe_Step_2.gml" `
  -c "gml_Script_textdata_en=Source\Modified GML\gml_Script_textdata_en.gml" `
  -c "gml_Script_textdata_ja=Source\Modified GML\gml_Script_textdata_ja.gml" `
  -o "Mod Files\data.win"

if ($LASTEXITCODE -ne 0) { throw "UndertaleModCli failed with exit code $LASTEXITCODE" }
```

Each `-c` maps one code-entry name inside `data.win` to one source file. The
entry names are UndertaleModTool's exported names; do not rename the files
or the entries. The quoted value is required because the source folder name
contains a space.

The CLI reads the original file and writes `Mod Files\data.win`; it does not
modify `C:\Build\undertale-original\data.win`.

### Verify the rebuilt data file

```powershell
& $cli info "Mod Files\data.win"
Get-FileHash -Algorithm SHA256 -LiteralPath "Mod Files\data.win"
```

`info` must load successfully. With the supported original file and these
sources, the size must be `62927354` bytes and the SHA-256 must be:

```text
9B13774BD7EBEED1929885B8EFA8A906F40B2A9931467E811A6BFC8239899F39
```

A different hash is acceptable only if you deliberately changed the source.
Any change requires updating the installer constants in step 8 and
re-testing installation, uninstallation and gameplay.

Optional spot check of a modified entry:

```powershell
& $cli dump "Mod Files\data.win" `
  -c "gml_Object_obj_settingsmenu_Draw_0" `
  -o "C:\Build\dump"
Select-String -Path "C:\Build\dump\CodeEntries\gml_Object_obj_settingsmenu_Draw_0.gml" `
  -Pattern "control_scheme"
```

## 7. Compile the installer

The installer source is `Installer\Installer_Source\installer.iss`. Its
relative paths are:

- `..\..\Mod Files\data.win`
- `..\..\Mod Files\README.txt`

Therefore steps 5 and 6 must be completed before compiling. Locate `ISCC.exe`:

```powershell
Get-Command ISCC.exe -ErrorAction SilentlyContinue
```

With Inno Setup 6.7.3 installed for the current user, the common path is:

```powershell
& "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe" `
  "Installer\Installer_Source\installer.iss"
```

A system-wide Inno Setup installation typically uses:

```powershell
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" `
  "Installer\Installer_Source\installer.iss"
```

The script sets `OutputDir=..` and `OutputBaseFilename=Setup`, so a
successful compile writes:

```text
Installer\Setup.exe
```

Confirm the compiler exit code is `0` and that `Installer\Setup.exe` exists:

```powershell
if ($LASTEXITCODE -ne 0) { throw "ISCC failed with exit code $LASTEXITCODE" }
Get-Item "Installer\Setup.exe"
Get-FileHash -Algorithm SHA256 -LiteralPath "Installer\Setup.exe"
```

The published v1.0.0 installer is 33,896,044 bytes with SHA-256:

```text
2C270D3AD8F643D022A678E70D0F215613DD907CA24E4D152F536516136465E6
```

Inno Setup embeds timestamps, so recompiling can change the installer hash
even when the source is identical. Update the hash values in `README.md`
and `TEST_RESULTS.md` if you publish a rebuilt installer.

## 8. Update SHA-256 constants when the build changes

The installer refuses unknown game files. The four constants are near the
top of `Installer\Installer_Source\installer.iss`:

```pascal
ORIGINAL_SHA256 = 'b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7';
MOD_SHA256      = '9b13774bd7ebeed1929885b8efa8a906f40b2a9931467e811a6bfc8239899f39';
ORIGINAL_SIZE   = 62921978;
MOD_SIZE        = 62927354;
```

Rules:

- `ORIGINAL_SHA256` is the SHA-256 of the untouched `data.win` from the
  supported game version. It gates installation and validates the backup.
- `MOD_SHA256` is the SHA-256 of the file produced by step 6. It validates
  the packaged file during installation and detects an existing install.
- `ORIGINAL_SIZE` and `MOD_SIZE` are recorded in the backup manifest and
  documentation. The current installer verifies content by SHA-256; keep
  the sizes accurate anyway.
- Use lowercase hex in the `.iss` file. The script lowercases computed
  hashes before comparing. Uppercase in this document is only for display.

Get the values:

```powershell
(Get-FileHash -Algorithm SHA256 -LiteralPath "C:\Build\undertale-original\data.win").Hash
(Get-FileHash -Algorithm SHA256 -LiteralPath "Mod Files\data.win").Hash
(Get-Item "C:\Build\undertale-original\data.win").Length
(Get-Item "Mod Files\data.win").Length
```

Replace the corresponding constants in `installer.iss`, then recompile in
step 7. If `ORIGINAL_SHA256` changes, the supported-version statement in
`README.md`, `README.txt`, and the release notes must change too.

## 9. Test the build

Minimum checklist:

1. Back up your game's original `data.win` outside the game folder.
2. Run `Installer\Setup.exe` and select the game folder.
3. Confirm `wasd_mod_backup\data.win.original` was created and its hash
   matches the original.
4. Launch UNDERTALE, open **SETTINGS > CONTROL SCHEME**, switch between
   **WASD** and **ARROW KEYS**, and confirm both work.
5. Restart the game and confirm the `config.ini` choice persists.
6. Uninstall and confirm the original `data.win` hash is restored and that
   files under `%LOCALAPPDATA%\UNDERTALE` were not modified.

The installer is intentionally strict: an unknown `data.win`, a missing
backup, or a corrupt backup produces an error instead of overwriting files.

## 10. Do not publish game files

Never commit or upload:

- the original `data.win`;
- any rebuilt/modded `data.win`;
- `Backups/` containing game data;
- extracted game assets or the full exported script set;
- UndertaleModTool binaries.

The `.gitignore` excludes these paths. The released `Setup.exe` is the
mod distribution artifact and is built locally from your own game copy.
When in doubt, publish source and build instructions and let users build
against their own legitimate game installation.

## 11. Quick reproduction summary

From a fresh clone, on Windows with PowerShell:

```powershell
# 1. Dependencies: UndertaleModTool CLI 0.9.2.0 and Inno Setup 6.7.3.

# 2. Create build folders.
New-Item -ItemType Directory -Force "Mod Files" | Out-Null

# 3. Copy the player readme.
Copy-Item -LiteralPath "Source\MOD_README.txt" -Destination "Mod Files\README.txt" -Force

# 4. Build data.win (use the full 12-entry command from step 6).
#    Requires your own original data.win matching the supported hash.

# 5. Verify:
#    Mod Files\data.win = 62927354 bytes,
#    SHA-256 9b13774bd7ebeed1929885b8efa8a906f40b2a9931467e811a6bfc8239899f39

# 6. Compile the installer.
& "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe" "Installer\Installer_Source\installer.iss"

# 7. Result:
#    Installer\Setup.exe
```

Because the full `data.win` rebuild command contains all twelve `-c`
mappings, always copy it from step 6 rather than abbreviating it.
