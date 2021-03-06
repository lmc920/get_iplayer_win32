#pragma parseroption -p-
; #define DUMPISPP
; #define NOPERL
; #define NOUTILS
#ifndef GiPVersion
  #define GiPVersion "3.12"
#endif
#ifndef SetupBuild
  #define SetupBuild "0"
#endif
#expr Exec("make-gip.cmd", GiPVersion + ' ' + SetupBuild, SourcePath, 1, SW_HIDE)
#define SetupDir "build\\setup"
#define SetupSuffix '-setup'
#ifdef NOPERL
  #define SetupSuffix SetupSuffix + '-noperl'
#endif
#ifdef NOUTILS
  #define SetupSuffix SetupSuffix + '-noutils'
#endif
#define AppName "get_iplayer"
#define AppVersion GiPVersion + '.' + SetupBuild
#define GiPRepo "https://github.com/get-iplayer/get_iplayer"
#define GiPWiki GiPRepo + "/wiki"
#define GiPWin32Repo "https://github.com/get-iplayer/get_iplayer_win32"
#define GiPSrc "build\\get_iplayer\\get_iplayer-" + AppVersion
#define PerlSrc "build\\perl\\perl-5.26.1"
#define AtomicParsleySrc "utils\\AtomicParsley-0.9.6"
#define FFmpegSrc "utils\\ffmpeg-3.4-win32-static"
#define PerlDir "{app}\\perl"
#define UtilsDir "{app}\\utils"
#define LicensesDir UtilsDir + "\\licenses"
#define GiPIcon "{app}\\get_iplayer.ico"
#define GiPPVRIcon "{app}\\get_iplayer_pvr.ico"
#define HomeDir "%HOMEDRIVE%%HOMEPATH%"

[Setup]
AppCopyright=Copyright (C) 2008-2010 Phil Lewis
AppName={#AppName}
AppPublisher=The {#AppName} Contributors
AppPublisherURL={#GiPRepo}
AppSupportURL={#GiPWiki}
AppUpdatesURL={#GiPWin32Repo}/releases
AppVerName={#AppName} {#AppVersion}
AppVersion={#AppVersion}
ChangesEnvironment=yes
DefaultDirName={pf}\{#AppName}
DefaultGroupName={#AppName}
DisableDirPage=yes
DisableFinishedPage=no
DisableProgramGroupPage=yes
DisableReadyPage=no
DisableStartupPrompt=yes
DisableWelcomePage=no
LicenseFile={#GiPSrc}\LICENSE.txt
OutputBaseFilename={#AppName}-{#AppVersion}{#SetupSuffix}
OutputDir={#SetupDir}
SetupIconFile=get_iplayer.ico
UninstallDisplayIcon={app}\get_iplayer_uninst.ico

[Tasks]
Name: desktopicons; Description: Create &desktop shortcuts (for all users); Flags: unchecked;

[InstallDelete]
; ensure removal of obsolete system options
Type: files; Name: {commonappdata}\get_iplayer\options;
Type: dirifempty; Name: {commonappdata}\get_iplayer;
; ensure removal of obsolete uninstallers
Type: files; Name: {app}\Uninst.exe;
Type: files; Name: {app}\uninstall.exe;
#ifndef NOPERL
; reset perl on install
Type: filesandordirs; Name: {#PerlDir};
#endif
#ifndef NOUTILS
Type: dirifempty; Name: {#UtilsDir};
#endif
Type: dirifempty; Name: {app};

[UninstallDelete]
Type: files; Name: {app}\Setup Log*;

[Files]
Source: {#GiPSrc}\get_iplayer; DestDir: {app}; DestName: get_iplayer.pl;
Source: {#GiPSrc}\get_iplayer.cgi; DestDir: {app};
Source: get_iplayer.cmd; DestDir: {app};
Source: get_iplayer.cgi.cmd; DestDir: {app};
Source: get_iplayer_web_pvr.cmd; DestDir: {app};
Source: get_iplayer_pvr.cmd; DestDir: {app};
Source: get_iplayer.ico; DestDir: {app};
Source: get_iplayer_pvr.ico; DestDir: {app};
Source: get_iplayer_uninst.ico; DestDir: {app};
Source: {#SetupSetting('LicenseFile')}; DestDir: {app};
#ifndef NOPERL
Source: {#PerlSrc}\*; Excludes: "\MANIFEST,\META.yml,\script"; DestDir: {#PerlDir}; Flags: recursesubdirs createallsubdirs;
#endif
#ifndef NOUTILS
Source: sources.txt; DestDir: {#UtilsDir};
Source: {#AtomicParsleySrc}\AtomicParsley.exe; DestDir: {#UtilsDir};
Source: {#AtomicParsleySrc}\COPYING; DestDir: {#LicensesDir}\atomicparsley;
Source: {#FFmpegSrc}\bin\ffmpeg.exe; DestDir: {#UtilsDir}; MinVersion: 6.1;
Source: {#FFmpegSrc}\LICENSE.txt; DestDir: {#LicensesDir}\ffmpeg; MinVersion: 6.1;
Source: {#FFmpegSrc}\README.txt; DestDir: {#LicensesDir}\ffmpeg; MinVersion: 6.1;
#endif

[Icons]
Name: {group}\{#AppName}; Filename: {cmd}; \
  Parameters: /k get_iplayer.cmd --search dontshowanymatches && get_iplayer.cmd --help; \
  WorkingDir: {#HomeDir}; IconFilename: {#GiPIcon};
Name: {group}\Web PVR Manager; Filename: {cmd}; \
  Parameters: /c get_iplayer_web_pvr.cmd; WorkingDir: {#HomeDir}; IconFilename: {#GiPPVRIcon};
Name: {group}\Run PVR Scheduler; Filename: {cmd}; \
  Parameters: /k get_iplayer_pvr.cmd; WorkingDir: {#HomeDir}; IconFilename: {#GiPPVRIcon};
Name: {group}\Uninstall; Filename: {uninstallexe}; IconFilename: {#SetupSetting('UninstallDisplayIcon')};
Name: {group}\Help\{#AppName} Documentation; Filename: {#GiPWiki};
Name: {group}\Help\AtomicParsley Documentation; Filename: http://atomicparsley.sourceforge.net;
Name: {group}\Help\FFmpeg Documentation; Filename: http://ffmpeg.org/documentation.html;
Name: {group}\Help\Perl Documentation; Filename: http://perldoc.perl.org;
Name: {group}\Help\Strawberry Perl Home; Filename: http://strawberryperl.com;
Name: {group}\Update\Check for Update; Filename: {#SetupSetting('AppUpdatesURL')};
Name: {commondesktop}\{#AppName}; Filename: {cmd}; \
  Parameters: /k get_iplayer.cmd --search dontshowanymatches && get_iplayer.cmd --help; \
  WorkingDir: {#HomeDir}; IconFilename: {#GiPIcon}; Tasks: desktopicons;
Name: {commondesktop}\Web PVR Manager; Filename: {cmd}; \
  Parameters: /c get_iplayer_web_pvr.cmd; WorkingDir: {#HomeDir}; \
  IconFilename: {#GiPPVRIcon}; Tasks: desktopicons;
Name: {commondesktop}\Run PVR Scheduler; Filename: {cmd}; \
  Parameters: /k get_iplayer_pvr.cmd; WorkingDir: {#HomeDir}; \
  IconFilename: {#GiPPVRIcon}; Tasks: desktopicons;
Name: {commondesktop}\{#AppName} Documentation; Filename: {#GiPWiki}; Tasks: desktopicons;

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
  ValueType: expandsz; ValueName: "Path";  ValueData: "{olddata};{app}"; Check: PathCheck(ExpandConstant('{app}'));

[Run]
Filename: {#GiPWiki}/releasenotes; Description: View {#AppName} release notes; \
  Flags: postinstall shellexec skipifsilent nowait;
Filename: {group}\Help\{#AppName} Documentation.url; Description: View {#AppName} documentation; \
  Flags: postinstall shellexec skipifsilent nowait unchecked;
Filename: {cmd}; Parameters: "/k ""set ""PATH=%PATH%;{app}"" && get_iplayer.cmd --search dontshowanymatches && get_iplayer.cmd --help"""; \
  WorkingDir: {%HOMEDRIVE}{%HOMEPATH}; Description: Launch {#AppName};  \
  Flags: postinstall skipifsilent nowait unchecked;
Filename: {cmd}; Parameters: "/c ""set ""PATH=%PATH%;{app}"" && get_iplayer_web_pvr.cmd"""; \
  WorkingDir: {%HOMEDRIVE}{%HOMEPATH}; Description: Launch Web PVR Manager; \
  Flags: postinstall skipifsilent nowait unchecked;

[Messages]
BeveledLabel={#SetupSetting('AppVerName')}

[Code]
function NSISUninstall(): Integer;
var
  Uninstaller, Prompt: String;
  RC: Integer;
begin
  Log('NSISUninstall: enter');
  Result := IDOK;
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'Software\Microsoft\Windows\CurrentVersion\Uninstall\get_iplayer',
    'UninstallString', Uninstaller) then
  begin
    Log('NSISUninstall: uninstaller not defined');
    exit;
  end;
  Log('NSISUninstall: uninstaller=' + Uninstaller);
  if not FileExists(Uninstaller) then
  begin
    Log('NSISUninstall: uninstaller not found');
    exit;
  end;
  if Pos('Uninst.exe', Uninstaller) > 0 then
  begin
    // get_iplayer 2.94.0/installer 4.9 or earlier
    Prompt := 'Setup will now uninstall your previous version of {#AppName}. ';
    Prompt := Prompt + 'Select "No" when prompted to "Remove User Preferences, ' +
        'PVR Searches, Presets and Recording History". ';
    Prompt := Prompt + 'If you configured a custom output directory with a previous ' +
        'version of {#AppName} Setup, reconfigure it after installation with:' + #13#10#13#10 +
        '{#AppName} --prefs-add --output="your_custom_output_directory_here"';
    Prompt := Prompt + #13#10#13#10 + 'Click OK to continue or Cancel to exit setup';
    Result := MsgBox(Prompt, mbConfirmation, MB_OKCANCEL or MB_DEFBUTTON2);
  end
  else
  begin
    // get_iplayer 2.95.0 - 3.06.0
    Prompt := 'Setup will now uninstall your previous version of {#AppName}. ';
    Prompt := Prompt + #13#10#13#10 + 'Click OK to continue or Cancel to exit setup';
    Result := SuppressibleMsgBox(Prompt, mbConfirmation, MB_OKCANCEL or MB_DEFBUTTON2, IDOK);
  end;
  if Result = IDCANCEL then
  begin
    Log('NSISUninstall: cancelled');
    exit;
  end;
  if not Exec(Uninstaller, '/S _?=' + ExtractFileDir(Uninstaller), '', SW_SHOW,
      ewWaitUntilTerminated, RC) then
  begin
    Log(Format('NSISUninstall: uninstaller error: rc=%d msg=%s', [RC, SysErrorMessage(RC)]));
    Prompt := 'Uninstall of your previous version of {#AppName} generated an error.';
    Prompt := Prompt + #13#10#13#10 + Format('ERROR: Code=%d Message=%s', [RC, SysErrorMessage(RC)]);
  end
  else
    if RC <> 0 then
    begin
      Log(Format('NSISUninstall: uninstaller aborted: rc=%d', [RC]));
      Prompt := 'Uninstall of your previous version of {#AppName} was aborted.';
    end;
  begin
  end;
  if RC <> 0 then
  begin
    Log('NSISUninstall: failed');
    Prompt := Prompt + #13#10#13#10 + 'Uninstall your previous version of {#AppName} ' +
        'in Windows Control Panel and then re-run {#AppName} Setup.'
    SuppressibleMsgBox(Prompt, mbError, MB_OK, IDOK);
    Result := IDCANCEL;
  end;
  Log(Format('NSISUninstall: exit=%d', [Result]));
end;

function IsWindows7OrLater(): Boolean;
begin
  Result := (GetWindowsVersion() >= $06010000);
end;

function XPVistaWarning(): Integer;
var
  Prompt: String;
begin
  Result := IDOK;
  Prompt := 'NOTE: {#AppName} is not supported by the developer for use on Windows XP or Vista. ' +
      'Windows 7 is the minimum version required by the bundled version of ffmpeg. ' +
      'ffmpeg is not required to download programmes, but it is required to convert ' +
      'output files to MP4 and to add metadata tags. If you wish to use get_iplayer ' +
      'on Windows XP or Vista, you must install a compatible version of ffmpeg in ' +
      'the following directory:' + #13#10#13#10 +
      ExpandConstant('{#UtilsDir}') + #13#10#13#10 +
      'Click OK to continue or Cancel to exit setup';
  Result := MsgBox(Prompt, mbConfirmation, MB_OKCANCEL or MB_DEFBUTTON2);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  RC: Integer;
begin
  if not IsWindows7OrLater() then
  begin
    RC := XPVistaWarning();
    if RC = IDCANCEL then
    begin
      Result := 'Setup cancelled';
      exit;
    end;
  end;
  RC := NSISUninstall();
  if RC = IDCANCEL then
  begin
    Result := 'Setup cancelled';
    exit;
  end;
end;

function CopyLog(): Boolean;
var
  LogFile, LogFileName, LogFileCopy: String;
begin
  Result := False
  LogFile := ExpandConstant('{log}');
  if (Length(LogFile) > 0) and (FileExists(LogFile)) then
  begin
    LogFileName := ExtractFileName(LogFile);
    LogFileCopy := ExpandConstant('{app}\' + LogFileName);
    Result := FileCopy(LogFile, LogFileCopy, False);
  end;
end;

// function ShouldSkipPage(PageID: Integer): Boolean;
// begin
//   Result := False;
//   if (PageID = wpReady) and (not IsTaskSelected('desktopicons')) then
//     Result := True;
// end;

function PathCheck(Param: string): Boolean;
var
    OrigPath: String;
    Index: Integer;
begin
  Log('PathCheck: enter');
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath) then
  begin
    Log('PathCheck: empty path');
    Result := True;
    exit;
  end;
  Index := Pos(';' + Param + ';', OrigPath + ';');
  Log(Format('PathCheck: index=%d path=%s', [Index, OrigPath]));
  if IsUninstaller() and (Index > 0) then
  begin
    Log('PathCheck: uninstall');
    Delete(OrigPath, Index, Length(Param) + 1);
    if not RegWriteStringValue(HKEY_LOCAL_MACHINE,
      'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
      'Path', OrigPath) then
    begin
      Log('PathCheck: write failed');
    end;
  end;
  Result := (Index = 0);
  Log(Format('PathCheck: exit=%d', [Result]));
 end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssDone then
  begin
    CopyLog();
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then
  begin
    PathCheck(ExpandConstant('{app}'));
  end;
end;

#ifdef DUMPISPP
  #expr SaveToFile(AddBackslash(SourcePath) + "get_iplayer.ispp.iss")
#endif
