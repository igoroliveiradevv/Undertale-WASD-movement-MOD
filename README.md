# Undertale WASD Controls Mod

An optional WASD control scheme for the Steam PC release of UNDERTALE.
Arrow keys remain available, so the game stays fully playable with either
layout and with a controller.

> Building from source? See [BUILD.md](BUILD.md) for dependencies,
> the complete rebuild commands, and installer compilation steps.

- Mod version: **1.0.0**
- Nexus Mods: https://www.nexusmods.com/undertale/mods/54
- GitHub: https://github.com/igoroliveiradevv/Undertale-WASD-movement-MOD
- Download: see **Releases**
- Installer: `Installer/Setup.exe`
- Installer source: `Installer/Installer_Source/installer.iss`
- Build instructions: [BUILD.md](BUILD.md)
- Installer binary: `Installer/Setup.exe`

## What the mod does

Adds a **CONTROL SCHEME** option to the in-game SETTINGS menu:

| Option | Behaviour |
|---|---|
| ARROW KEYS | Original game behaviour (default) |
| WASD | W/A/S/D move; arrow keys still work as a fallback |

The choice is written to `config.ini` and persists across restarts:

```ini
[General]
cs="1.000000"
```

`cs=0` means Arrow Keys, `cs=1` means WASD.

WASD support covers:

- Overworld movement and interaction
- Battle menu navigation
- Red, blue and purple SOUL movement
- Boss SOUL movement, including the sans battle
- Dialogue choices
- Settings and joystick menus
- Shootguy and Asgore spear-swipe sections

Action buttons are unchanged:

- Confirm: Z / Enter
- Cancel: X / Shift
- Menu: C / Ctrl

## Supported game versions

**Supported and tested:** Steam PC release of UNDERTALE whose original
`data.win` is:

- Size: 62,921,978 bytes
- SHA-256: `b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7`

The installer checks this hash and refuses to modify an unknown or
already-modded game file. This protects saves and prevents a bad backup.

**Not supported / not tested:**

- GOG or other store builds
- Any Steam update that changes `data.win`
- Games with other mods already applied (verify files in Steam first)
- Console or mobile versions

If Steam updates UNDERTALE, the mod must be rebuilt for the new
`data.win`; the installer will report an unsupported version instead of
forcing installation.

## Installation

1. Close UNDERTALE.
2. Run `Installer/Setup.exe`.
3. Select your UNDERTALE folder (the one containing `UNDERTALE.exe` and
   `data.win`). The installer tries to detect the Steam library
   automatically.
4. Continue. The installer:
   - validates the game version,
   - creates a verified backup,
   - installs the modified `data.win`,
   - verifies the installed file.
5. Start UNDERTALE.

The installer needs write access to the game folder. If the game is in
`Program Files`, run Setup as administrator or choose the administrative
install mode if prompted.

## Selecting WASD inside UNDERTALE

1. Launch UNDERTALE.
2. Open **SETTINGS**.
3. Select **CONTROL SCHEME**.
4. Choose **WASD** or **ARROW KEYS**.
5. Press Z / Enter, then exit the settings menu.

The setting is saved when you leave SETTINGS. Pressing A/D (or Left/Right)
also switches the value; W/S (or Up/Down) moves through the menu.

## Switching back to Arrow Keys

Open **SETTINGS > CONTROL SCHEME** and choose **ARROW KEYS**, or use
**RESET TO DEFAULT** in the settings menu. The mod remains installed but
behaves exactly like the original game.

## Uninstallation

Use either:

- Windows **Settings > Apps > Installed apps > Undertale WASD Controls Mod >
  Uninstall**, or
- `unins000.exe` in the game folder.

The uninstaller:

1. verifies the backup hash,
2. restores `data.win`,
3. verifies the restored file,
4. only then removes the backup and the mod's readme.

Save files in `%LOCALAPPDATA%\UNDERTALE` are never touched.

If the backup is missing or corrupt, the uninstaller does **not** delete
anything and tells you where the backup is. In that case, use Steam >
Properties > Installed Files > **Verify integrity of game files**.

## Backup and restoration behaviour

On installation, the installer creates:

```text
<game folder>\wasd_mod_backup\
    data.win.original
    backup_info.txt
```

- `data.win.original` is the untouched original game file.
- `backup_info.txt` records its SHA-256, size, creation time and the mod
  build hash.
- A backup is only accepted if its SHA-256 matches the supported original
  hash.
- An existing valid backup is never overwritten.
- If an invalid backup is found while the game is still original, it is
  renamed with an `.invalid-<timestamp>` suffix instead of being silently
  replaced.
- Installation replaces `data.win` through a verified temporary file and
  keeps a rollback copy until the new file passes its hash check.
- The backup stays in a persistent folder inside the game directory and
  survives reboots and installer restarts.

Earlier test builds could report *"Could not restore the original
data.win"*. The cause was an incorrect `CopyFile` flag (it was told to
fail if the destination existed) plus a mistyped mod hash constant. Both
are fixed, and restoration is now verified by hash before the backup is
removed.

## Troubleshooting

**"UNDERTALE.exe was not found" / "data.win was not found"**
Select the actual game folder. In Steam: right-click UNDERTALE >
Manage > Browse local files.

**"Unsupported or modified UNDERTALE data.win"**
Steam has updated the game, another mod is installed, or the copy is from
another store. Verify the game files in Steam, then check whether a newer
version of this mod is available.

**"The mod is already installed, but no valid original backup was found"**
Verify the game files in Steam (this restores the original `data.win`),
then run Setup again. The installer will make a fresh backup.

**Installation cannot write data.win**
Close UNDERTALE and any antivirus scan holding the file. If the game is
in `Program Files`, run Setup as administrator.

**Game does not start after installing**
Uninstall the mod (or verify files in Steam) to restore the original
`data.win`. Report the game version and the installer log if possible.

**Steam verified the files and the mod disappeared**
That is expected: Steam restores the original `data.win`. Reinstall the
mod afterwards.

## Package contents

```text
Undertale-WASD-movement-MOD/
|-- BUILD.md
|-- LICENSE
|-- README.md
|-- CHANGELOG.md
|-- TEST_RESULTS.md
|-- Installer/
|   |-- Setup.exe
|   `-- Installer_Source/
|       `-- installer.iss
`-- Source/
    |-- README.md
    |-- MOD_README.txt
    `-- Modified GML/
        `-- (12 modified .gml files)
```

Game data (`data.win`), backups and development tools are not committed
to the repository. The compiled installer embeds the modded game data and
is distributed through Releases.

## License

MIT License. See [LICENSE](LICENSE).

You may use, copy, modify, merge, publish, distribute, sublicense and sell
this project, including as part of other projects, as long as the original
copyright notice and permission notice are retained and credit is given to
the original author, Igor Oliveira (igoroliveiradevv).
## Verification data

- Original `data.win` SHA-256:
  `b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7`
- Modded `data.win` SHA-256:
  `9b13774bd7ebeed1929885b8efa8a906f40b2a9931467e811a6bfc8239899f39`
- `Setup.exe` SHA-256:
  `2c270d3ad8f643d022a678e70d0f215613dd907ca24e4d152f536516136465e6`
  (33,896,044 bytes)
