; ============================================================================
;  Undertale WASD Controls Mod - installer source
;  Build: ISCC.exe installer.iss   (output: ..\Setup.exe)
;
;  The constants below identify the supported game build and the packaged mod.
;  If the mod data.win is ever rebuilt, update MOD_SHA256 and MOD_SIZE.
; ============================================================================

#define MyAppName "Undertale WASD Controls Mod"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Undertale WASD Mod Project"
#define MyAppExeName "UNDERTALE.exe"

[Setup]
AppId={{5E7A9C21-8B4D-4F6A-9E3C-2D1B0A9F8E76}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={code:GetDefaultGameDir}
DisableDirPage=no
UsePreviousAppDir=yes
DirExistsWarning=no
OutputDir=..
OutputBaseFilename=Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
UninstallDisplayName={#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
VersionInfoVersion=1.0.0.0
VersionInfoDescription=Undertale WASD Controls Mod Setup
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
WelcomeLabel2=This will install [name/ver] on your computer.%n%nIt adds an optional WASD control scheme to UNDERTALE and creates a verified backup of data.win before changing anything.

[Files]
; The modded data.win is handled entirely by [Code] so that backup, hashing and
; safe replacement are under our control. dontcopy extracts it to {tmp} on demand.
Source: "..\..\Mod Files\data.win"; Flags: dontcopy noencryption
; Small documentation file, managed by the uninstaller automatically.
Source: "..\..\Mod Files\README.txt"; DestDir: "{app}"; DestName: "WASD_MOD_README.txt"; Flags: ignoreversion

[Code]
const
  ORIGINAL_SHA256 = 'b718f8223a5bb31979ffeed10be6140c857b882fc0d0462b89d6287ae38c81c7';
  MOD_SHA256      = '9b13774bd7ebeed1929885b8efa8a906f40b2a9931467e811a6bfc8239899f39';
  ORIGINAL_SIZE   = 62921978;
  MOD_SIZE        = 62927354;
  BACKUP_FOLDER   = 'wasd_mod_backup';
  BACKUP_FILENAME = 'data.win.original';

var
  InstallMode: string;      // 'fresh' or 'reinstall'
  InstalledOK: Boolean;
  ImportedLegacy: Boolean;

function ShowMsg(const Text: string; Typ: TMsgBoxType): Integer;
begin
  Result := SuppressibleMsgBox(Text, Typ, MB_OK, IDOK);
end;

{ ---------------------------------------------------------------- helpers }

function GameDir: string;
begin
  Result := ExpandConstant('{app}');
end;

function DataFile: string;
begin
  Result := AddBackslash(GameDir) + 'data.win';
end;

function ExeFile: string;
begin
  Result := AddBackslash(GameDir) + '{#MyAppExeName}';
end;

function BackupDir: string;
begin
  Result := AddBackslash(GameDir) + BACKUP_FOLDER;
end;

function BackupFile: string;
begin
  Result := AddBackslash(BackupDir) + BACKUP_FILENAME;
end;

function ManifestFile: string;
begin
  Result := AddBackslash(BackupDir) + 'backup_info.txt';
end;

function LegacyBackupFile: string;
begin
  Result := AddBackslash(GameDir) + 'data.win.wasd_backup';
end;

function SHA256(const Filename: string): string;
begin
  Result := Lowercase(GetSHA256OfFile(Filename));
end;

function IsOriginalData(const Filename: string): Boolean;
begin
  Result := FileExists(Filename) and (SHA256(Filename) = ORIGINAL_SHA256);
end;

function IsModData(const Filename: string): Boolean;
begin
  Result := FileExists(Filename) and (SHA256(Filename) = MOD_SHA256);
end;

function BackupIsValid: Boolean;
begin
  Result := FileExists(BackupFile) and (SHA256(BackupFile) = ORIGINAL_SHA256);
end;

function TimestampSuffix: string;
begin
  Result := GetDateTimeString('yyyymmdd-hhnnss', '-', ':');
end;

procedure WriteManifest;
var
  S: string;
begin
  S := 'Undertale WASD Controls Mod - original file backup' + #13#10 +
       'Created: ' + GetDateTimeString('yyyy-mm-dd hh:nn:ss', '-', ':') + #13#10 +
       'OriginalFile=data.win' + #13#10 +
       'OriginalSHA256=' + ORIGINAL_SHA256 + #13#10 +
       'OriginalSize=' + IntToStr(ORIGINAL_SIZE) + #13#10 +
       'ModSHA256=' + MOD_SHA256 + #13#10 +
       'ModSize=' + IntToStr(MOD_SIZE) + #13#10 +
       'InstallerVersion={#MyAppVersion}' + #13#10;
  SaveStringToFile(ManifestFile, S, False);
end;

{ Copies SourceFile into the backup folder via a temporary file, verifies the
  hash, and only then promotes it to the final backup name. Returns '' on
  success or a human-readable error. }
function CreateBackupFrom(const SourceFile: string): string;
var
  TmpFile: string;
begin
  Result := '';
  if not ForceDirectories(BackupDir) then
  begin
    Result := 'Could not create the backup folder:' + #13#10 + BackupDir;
    Exit;
  end;

  TmpFile := BackupFile + '.tmp';
  if FileExists(TmpFile) then
    DeleteFile(TmpFile);

  if not CopyFile(SourceFile, TmpFile, False) then
  begin
    Result := 'Could not copy the original data.win to the backup folder.';
    Exit;
  end;

  if SHA256(TmpFile) <> ORIGINAL_SHA256 then
  begin
    DeleteFile(TmpFile);
    Result := 'Backup verification failed: the copied file does not match the' + #13#10 +
              'supported original data.win. Nothing was changed.';
    Exit;
  end;

  { Never silently replace an existing valid backup. An invalid one is kept
    under a new name for diagnosis. }
  if FileExists(BackupFile) then
  begin
    if BackupIsValid then
    begin
      DeleteFile(TmpFile);
      WriteManifest;
      Exit;
    end;
    RenameFile(BackupFile, BackupFile + '.invalid-' + TimestampSuffix);
  end;

  if not RenameFile(TmpFile, BackupFile) then
  begin
    DeleteFile(TmpFile);
    Result := 'Could not finalize the backup file:' + #13#10 + BackupFile;
    Exit;
  end;

  if not BackupIsValid then
  begin
    Result := 'Backup verification failed after creation. Nothing was changed.';
    Exit;
  end;

  WriteManifest;
end;

function ImportLegacyBackup: Boolean;
begin
  Result := False;
  if not IsOriginalData(LegacyBackupFile) then
    Exit;

  if CreateBackupFrom(LegacyBackupFile) = '' then
  begin
    ImportedLegacy := True;
    Result := True;
  end;
end;

{ ----------------------------------------------------------- default folder }

function GetDefaultGameDir(Param: string): string;
var
  Candidate, SteamPath: string;
begin
  Result := 'C:\Program Files (x86)\Steam\steamapps\common\Undertale';

  if RegQueryStringValue(HKLM32,
       'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 391540',
       'InstallLocation', Candidate) then
  begin
    if Candidate <> '' then
    begin
      Result := Candidate;
      Exit;
    end;
  end;

  if RegQueryStringValue(HKCU, 'Software\Valve\Steam', 'SteamPath', SteamPath) then
  begin
    Candidate := AddBackslash(SteamPath) + 'steamapps\common\Undertale';
    if DirExists(Candidate) then
      Result := Candidate;
  end;
end;

{ ------------------------------------------------------------- validation }

function DirectoryProblem(const Dir: string): string;
var
  Data, Exe: string;
begin
  Result := '';
  Data := AddBackslash(Dir) + 'data.win';
  Exe := AddBackslash(Dir) + '{#MyAppExeName}';

  if not DirExists(Dir) then
  begin
    Result := 'The selected folder does not exist.';
    Exit;
  end;

  if not FileExists(Data) then
  begin
    Result := 'data.win was not found in:' + #13#10 + Dir + #13#10#13#10 +
      'Select the folder that contains UNDERTALE.exe and data.win.';
    Exit;
  end;

  if not FileExists(Exe) then
  begin
    Result := '{#MyAppExeName} was not found in:' + #13#10 + Dir + #13#10#13#10 +
      'This does not look like an UNDERTALE installation folder.';
    Exit;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Problem: string;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    Problem := DirectoryProblem(WizardDirValue);
    if Problem <> '' then
    begin
      ShowMsg(Problem, mbError);
      Result := False;
    end;
  end;
end;

{ -------------------------------------------------------------- install flow }

function PrepareToInstall(var NeedsRestart: Boolean): string;
var
  CurrentHash, Problem: string;
begin
  Result := '';
  NeedsRestart := False;
  InstalledOK := False;
  ImportedLegacy := False;
  InstallMode := '';

  Problem := DirectoryProblem(GameDir);
  if Problem <> '' then
  begin
    Result := Problem;
    Exit;
  end;

  CurrentHash := SHA256(DataFile);

  if CurrentHash = MOD_SHA256 then
  begin
    InstallMode := 'reinstall';

    if not BackupIsValid then
    begin
      { No usable backup: try the legacy backup produced by older versions. }
      if not ImportLegacyBackup then
      begin
        Result := 'The mod is already installed, but no valid original backup was found.' + #13#10#13#10 +
          'To install safely, right-click UNDERTALE in Steam, open' + #13#10 +
          'Properties > Installed Files > Verify integrity of game files,' + #13#10 +
          'then run this installer again. No files were changed.';
        Exit;
      end;
    end;
  end
  else if CurrentHash = ORIGINAL_SHA256 then
  begin
    InstallMode := 'fresh';

    if not BackupIsValid then
    begin
      { Preserve an invalid old backup instead of overwriting it silently. }
      if FileExists(BackupFile) then
        RenameFile(BackupFile, BackupFile + '.invalid-' + TimestampSuffix);

      Problem := CreateBackupFrom(DataFile);
      if Problem <> '' then
      begin
        Result := Problem;
        Exit;
      end;
    end
    else
      WriteManifest;
  end
  else
  begin
    Result := 'Unsupported or modified UNDERTALE data.win.' + #13#10#13#10 +
      'Found SHA-256:' + #13#10 + CurrentHash + #13#10#13#10 +
      'This installer supports the Steam release with original data.win' + #13#10 +
      'SHA-256 ' + ORIGINAL_SHA256 + '.' + #13#10#13#10 +
      'If Steam updated the game, this mod build is not compatible.' + #13#10 +
      'If another mod is installed, verify the game files in Steam first.' + #13#10#13#10 +
      'No files were changed.';
    Exit;
  end;
end;

procedure RestoreFromBackupQuiet;
var
  RestoreTmp: string;
begin
  if not BackupIsValid then
    Exit;

  RestoreTmp := DataFile + '.restore_tmp';
  if FileExists(RestoreTmp) then
    DeleteFile(RestoreTmp);

  if CopyFile(BackupFile, RestoreTmp, False) then
  begin
    if SHA256(RestoreTmp) = ORIGINAL_SHA256 then
    begin
      if FileExists(DataFile) then
        DeleteFile(DataFile);
      RenameFile(RestoreTmp, DataFile);
    end;
  end;
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  TmpMod, NewFile, OldFile: string;
begin
  if CurStep = ssInstall then
  begin
    WizardForm.StatusLabel.Caption := 'Installing modified game files...';

    try
      ExtractTemporaryFile('data.win');
    except
      ShowMsg('Could not unpack the modded data.win from the installer.', mbError);
      Abort;
    end;

    TmpMod := ExpandConstant('{tmp}\data.win');
    Log('Extracted mod hash: ' + SHA256(TmpMod));
    Log('Expected mod hash:  ' + MOD_SHA256);
    if SHA256(TmpMod) <> MOD_SHA256 then
    begin
      ShowMsg('The bundled modded data.win failed its integrity check.' + #13#10 +
        'The installation was cancelled and no game files were changed.', mbError);
      Abort;
    end;

    NewFile := DataFile + '.wasd_new';
    OldFile := DataFile + '.wasd_old';

    if FileExists(NewFile) then DeleteFile(NewFile);
    if FileExists(OldFile) then DeleteFile(OldFile);

    if not CopyFile(TmpMod, NewFile, False) then
    begin
      ShowMsg('Could not write the new data.win into the game folder.' + #13#10 +
        'No game files were changed.', mbError);
      Abort;
    end;

    if SHA256(NewFile) <> MOD_SHA256 then
    begin
      DeleteFile(NewFile);
      ShowMsg('The copied data.win failed verification.' + #13#10 +
        'No game files were changed.', mbError);
      Abort;
    end;

    { Keep the current file as a rollback copy until the new one is verified. }
    if not RenameFile(DataFile, OldFile) then
    begin
      DeleteFile(NewFile);
      ShowMsg('Could not prepare data.win for replacement.' + #13#10 +
        'Close UNDERTALE and try again. No game files were changed.', mbError);
      Abort;
    end;

    if not RenameFile(NewFile, DataFile) then
    begin
      RenameFile(OldFile, DataFile);
      ShowMsg('Could not activate the modified data.win. The original file was kept.', mbError);
      Abort;
    end;

    if not IsModData(DataFile) then
    begin
      DeleteFile(DataFile);
      if FileExists(OldFile) then
        RenameFile(OldFile, DataFile);
      RestoreFromBackupQuiet;
      ShowMsg('The installed data.win failed verification and was rolled back.', mbError);
      Abort;
    end;

    DeleteFile(OldFile);
    InstalledOK := True;
  end
  else if CurStep = ssPostInstall then
  begin
    if InstalledOK then
    begin
      { Remove the legacy loose backup only after the new backup and install
        have both been verified. }
      if ImportedLegacy and FileExists(LegacyBackupFile) then
        DeleteFile(LegacyBackupFile);
    end;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (CurPageID = wpFinished) and InstalledOK then
  begin
    if InstallMode = 'reinstall' then
      WizardForm.FinishedLabel.Caption :=
        'The Undertale WASD Controls Mod has been refreshed successfully.' + #13#10#13#10 +
        'In UNDERTALE, open SETTINGS > CONTROL SCHEME and choose WASD.' + #13#10 +
        'Your original data.win backup is stored in:' + #13#10 + BackupDir
    else
      WizardForm.FinishedLabel.Caption :=
        'The Undertale WASD Controls Mod has been installed successfully.' + #13#10#13#10 +
        'In UNDERTALE, open SETTINGS > CONTROL SCHEME and choose WASD.' + #13#10 +
        'Your original data.win backup is stored in:' + #13#10 + BackupDir;
  end;
end;

{ ------------------------------------------------------------ uninstall flow }

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  RestoreTmp, OldUninstall: string;
begin
  if CurUninstallStep <> usPostUninstall then
    Exit;

  if not FileExists(BackupFile) then
  begin
    ShowMsg('No original data.win backup was found at:' + #13#10 +
      BackupFile + #13#10#13#10 +
      'The modded data.win was left untouched.' + #13#10 +
      'Use Steam > Properties > Installed Files > Verify integrity of game files' + #13#10 +
      'to restore the original game data.', mbInformation);
    Exit;
  end;

  if SHA256(BackupFile) <> ORIGINAL_SHA256 then
  begin
    ShowMsg('The backup file failed its integrity check and was NOT used:' + #13#10 +
      BackupFile + #13#10#13#10 +
      'The backup and the current game files were preserved.' + #13#10 +
      'Restore the game through Steam if needed.', mbError);
    Exit;
  end;

  RestoreTmp := DataFile + '.restore_tmp';
  if FileExists(RestoreTmp) then
    DeleteFile(RestoreTmp);

  if not CopyFile(BackupFile, RestoreTmp, False) then
  begin
    ShowMsg('Could not create the restored data.win.' + #13#10 +
      'The backup was preserved at:' + #13#10 + BackupFile, mbError);
    Exit;
  end;

  if SHA256(RestoreTmp) <> ORIGINAL_SHA256 then
  begin
    DeleteFile(RestoreTmp);
    ShowMsg('The restored file failed verification.' + #13#10 +
      'The backup was preserved at:' + #13#10 + BackupFile, mbError);
    Exit;
  end;

  { Move the current modded file aside first, so the restore rename can never
    fail because the destination exists. Keep it until restoration is verified. }
  OldUninstall := DataFile + '.wasd_uninstall_old';
  if FileExists(OldUninstall) then
    DeleteFile(OldUninstall);

  if FileExists(DataFile) then
  begin
    if not RenameFile(DataFile, OldUninstall) then
    begin
      DeleteFile(RestoreTmp);
      ShowMsg('Could not move the current data.win aside.' + #13#10 +
        'The backup was preserved at:' + #13#10 + BackupFile, mbError);
      Exit;
    end;
  end;

  if not RenameFile(RestoreTmp, DataFile) then
  begin
    if FileExists(OldUninstall) then
      RenameFile(OldUninstall, DataFile);
    DeleteFile(RestoreTmp);
    ShowMsg('Could not restore data.win.' + #13#10 +
      'The backup was preserved at:' + #13#10 + BackupFile, mbError);
    Exit;
  end;

  if not IsOriginalData(DataFile) then
  begin
    DeleteFile(DataFile);
    if FileExists(OldUninstall) then
      RenameFile(OldUninstall, DataFile);
    ShowMsg('Restoration verification failed.' + #13#10 +
      'The backup was preserved at:' + #13#10 + BackupFile, mbError);
    Exit;
  end;

  if FileExists(OldUninstall) then
    DeleteFile(OldUninstall);

  { Restoration is verified: only now remove the backup and its manifest. }
  DeleteFile(ManifestFile);
  DeleteFile(BackupFile);
  RemoveDir(BackupDir);

  if FileExists(LegacyBackupFile) then
    DeleteFile(LegacyBackupFile);

  ShowMsg('Uninstallation complete.' + #13#10#13#10 +
    'The original data.win was restored and verified.' + #13#10 +
    'Save files were not touched.', mbInformation);
end;
