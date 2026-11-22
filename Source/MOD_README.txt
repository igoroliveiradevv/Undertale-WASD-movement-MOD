UNDERTALE WASD CONTROLS MOD
===========================

Adds an optional WASD control scheme to UNDERTALE.

HOW TO USE
----------
1. Launch UNDERTALE.
2. Open SETTINGS.
3. Select CONTROL SCHEME.
4. Choose WASD or ARROW KEYS.
5. Press Z / Enter to confirm, then exit the menu.

The choice is stored in config.ini and persists between sessions.
While WASD is selected, arrow keys also keep working as a fallback.

COVERAGE
--------
- Overworld movement and interactions
- Battle menu navigation
- Red, blue and purple SOUL movement
- Boss SOUL movement
- Dialogue choices
- Settings and joystick menus

ACTION BUTTONS
--------------
Confirm: Z / Enter
Cancel:  X / Shift
Menu:    C / Ctrl

BACKUP AND RESTORE
------------------
The installer creates this folder next to the game's data.win:

  wasd_mod_backup\
    data.win.original
    backup_info.txt

data.win.original is the untouched original game file. backup_info.txt
records its SHA-256 hash.

Uninstalling restores data.win from that backup, verifies the restored
file, and only then removes the backup. If restoration fails, the backup
is preserved and the installer tells you where it is.

Steam's "Verify integrity of game files" also restores the original
data.win, but it will undo the mod.

SAVE FILES
----------
Save files live in %LOCALAPPDATA%\UNDERTALE and are never touched by this
mod or its installer/uninstaller.

SUPPORTED GAME VERSION
----------------------
This build targets the current Steam PC release of UNDERTALE whose
original data.win has SHA-256:

  b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7

Other versions, other stores, or already-modded game files are rejected
by the installer for safety.
