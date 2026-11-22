# Changelog

All notable changes to the Undertale WASD Controls Mod.

## [1.0.0] - 2026-11-22

### Added

- In-game **CONTROL SCHEME** setting with `ARROW KEYS` and `WASD`.
- Persistence through `config.ini` (`[General] cs=0/1`).
- WASD support for:
  - overworld movement
  - battle menu navigation
  - red, blue and purple SOUL movement
  - sans battle SOUL movement
  - dialogue choices
  - shootguy and Asgore spear-swipe sections
  - settings and joystick menus
- English and Japanese menu strings.
- Standalone graphical installer with:
  - automatic Steam library detection and manual folder selection
  - `data.win` and `UNDERTALE.exe` validation
  - game version validation by SHA-256
  - already-installed detection
  - verified backup in a persistent `wasd_mod_backup` folder
  - hash-verified, rollback-safe file replacement
  - verified uninstallation and optional backup preservation on failure

### Fixed

- Old test installers could report **"Could not restore the original
  data.win"** because `CopyFile` was called with `FailIfExists = True`
  while restoring over an existing file.
- A mistyped modded `data.win` SHA-256 constant caused installations to
  abort even when the bundled file was correct.
- The uninstaller previously restored files during `usUninstall`, after
  which Inno Setup could delete them. Restoration now happens in
  `usPostUninstall`, and the restored file is re-verified by hash.

### Changed

- Installer rewritten with hash checks, explicit install modes
  (`fresh` / `reinstall`), legacy backup migration, and a dedicated
  backup directory instead of a loose `data.win.wasd_backup` file.
- Mod documentation rewritten for players (`README.md`,
  `Mod Files/README.txt`).

### Tested

See `TEST_RESULTS.md` for the full matrix, including fresh install,
reinstall, repeated install, uninstall, restore, invalid folder,
incompatible version, missing backup, corrupt backup, save-file
preservation, and a real game install/launch/uninstall cycle.

## [0.9.0] - 2026-11-22

### Added

- Initial working mod implementation and experimental installer.
- Manual test build installed into the local Steam copy.
