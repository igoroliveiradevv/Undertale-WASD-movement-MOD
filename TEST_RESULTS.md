# Test Results

- Date: 2026-11-22
- OS: Windows 10.0.26100 (64-bit)
- Installer: Inno Setup 6.7.3
- Setup.exe: 33,896,044 bytes
- Setup.exe SHA-256:
  `2c270d3ad8f643d022a678e70d0f215613dd907ca24e4d152f536516136465e6`
- Modded data.win SHA-256:
  `9b13774bd7ebeed1929885b8efa8a906f40b2a9931467e811a6bfc8239899f39`
- Original data.win SHA-256:
  `b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7`

Tests were run silently with `/VERYSILENT /SUPPRESSMSGBOXES /NORESTART`
and checked with SHA-256 hashes and exit codes. Fresh/reinstall/uninstall/
failure scenarios were run against disposable game folders containing a
real copy of the original `data.win` and a dummy `UNDERTALE.exe`.
The final `Setup.exe` build was additionally tested end-to-end against the
real Steam installation.

## Matrix

| # | Scenario | Expected | Actual result | Status |
|---|---|---|---|---|
| 1 | Fresh installation | Backup created, modded data.win installed, README installed, exit 0 | Backup + manifest created, data.win hash = mod hash, README present, exit 0 | PASS |
| 2 | Install when mod already installed | Accepted as refresh; valid backup not overwritten | exit 0; backup hash and mtime unchanged | PASS |
| 3 | Repeated installation (two more runs) | Same as #2 | exit 0 both times; backup unchanged | PASS |
| 4 | Uninstallation | Original data.win restored, backup and mod readme removed, exit 0 | data.win hash = original; backup folder gone; README gone; exit 0 | PASS |
| 5 | Restoration of original files | Restored file matches original hash; backup removed only after verification | data.win hash = original; verified before cleanup | PASS |
| 6 | Invalid/empty game directory | Abort without writing, nonzero exit | exit 1, 0 files created | PASS |
| 7 | Mod installed but no backup present | Abort, preserve modded file, explain recovery | exit 7, modded data.win unchanged, no backup created | PASS |
| 8 | Incompatible/unknown data.win | Abort as unsupported version, no changes | exit 7, 20-byte dummy file unchanged, no backup | PASS |
| 9 | Legacy `data.win.wasd_backup` migration | Import valid legacy backup, install, remove legacy copy after success | New backup valid, install exit 0, legacy file removed | PASS |
| 10 | Uninstall with missing backup | Leave game files untouched, warn user | exit 0, modded data.win untouched, warning logged | PASS |
| 11 | Uninstall with corrupt backup | Preserve corrupt backup, do not use it | exit 0, backup preserved with original corrupt content, modded data.win untouched | PASS |
| 12 | Save files during real uninstall | Byte-for-byte unchanged | SHA-256 of `config.ini` and `undertale.ini` unchanged | PASS |
| 13 | Real Steam install + launch | Install exit 0, modded hash, game process stays alive | exit 0; `UNDERTALE.exe` ran for 10 s without exiting; process then terminated | PASS |
| 14 | Real Steam uninstall | Original restored, backups/readme removed | data.win hash = original; backup folder, legacy backup and readme gone; exit 0 | PASS |
| 15 | In-game visual check of both schemes | Toggle and play each scheme | Not automated. Installer/game launch verified; `config.ini` already contained `cs="1.000000"` from the earlier manual in-game test, and the mod was reported working before packaging. See limitation below. | LIMITED |

Final real-game cycle (run with the final Setup.exe hash above):

```text
install=0 data=9b13774bd7ebeed1929885b8efa8a906f40b2a9931467e811a6bfc8239899f39
game RUNNING
uninstall=0 data=b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7
backupdir=False readme=False
saves unchanged=True
```

## Root cause of the earlier restore warning

The previous installer restored with `CopyFile(backup, data.win, True)`.
In Inno Setup, the third parameter means **fail if the destination
exists**, so restoration failed whenever `data.win` was still present.
The corrected uninstaller:

1. verifies the backup hash,
2. copies the backup to a verified temporary file,
3. renames the current `data.win` aside,
4. renames the verified temporary file into place,
5. verifies the final file,
6. only then deletes the rollback copy and the backup.

A second bug found during testing was a mistyped SHA-256 constant for the
modded `data.win`; it made every fresh install abort at the integrity
check. The constant was corrected and all scenarios above were rerun.

## Limitations

- The in-game behaviour of both control schemes was not re-tested
  automatically because it requires interactive play. The mod was
  confirmed working before this packaging task, and the persisted
  `config.ini` value (`cs=1`) plus successful game launch were verified.
- Console/mobile variants and non-Steam stores were not available and are
  not claimed as supported.
- Steam updates after the tested build will be rejected as an unsupported
  version by design.
