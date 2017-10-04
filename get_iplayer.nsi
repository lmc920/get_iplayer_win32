;#######################################
;# Configuration
;#######################################

; name and version
!define PRODUCT "get_iplayer"
!define VERSION "3.04"
!define PATCHLEVEL "0"
!define WINVERSION "${VERSION}.${PATCHLEVEL}"
; set version strings in perl scripts
!system "make-version.cmd ${VERSION} ${PATCHLEVEL}"
; build dirs
!define BUILDDIR "build"
!define OUTDIR "${BUILDDIR}\installer"
!define GIPDIR "${BUILDDIR}\get_iplayer\get_iplayer-${VERSION}"
!define PERLDIR "${BUILDDIR}\perl\perl-5.24.1"
!define UTILSDIR "utils"
!define ATOMICPARSLEYDIR "${UTILSDIR}\AtomicParsley-0.9.6"
!define FFMPEGDIR "${UTILSDIR}\ffmpeg-3.3.3-win32-static"
; registry key for uninstall info
!define UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}"

;#######################################
;# Settings
;#######################################

BrandingText "${PRODUCT} ${WINVERSION}"
InstallDir "$PROGRAMFILES\${PRODUCT}"
Name "${PRODUCT}"
OutFile "${OUTDIR}\${PRODUCT}-${WINVERSION}.exe"
RequestExecutionLevel admin
SetCompressor /SOLID lzma
VIAddVersionKey "FileDescription" "${PRODUCT} ${WINVERSION}"
VIAddVersionKey "FileVersion" "${WINVERSION}.0"
VIAddVersionKey "LegalCopyright" "Copyright (C) 2008-2010 Phil Lewis"
VIAddVersionKey "ProductName" "${PRODUCT}"
VIAddVersionKey "ProductVersion" "${WINVERSION}.0"
VIProductVersion "${WINVERSION}.0"

;#######################################
;# Includes
;#######################################

; include before EnvVarUpdate.nsh
!include StrFunc.nsh
; string function defs must be expanded before use
${StrLoc}
!include EnvVarUpdate.nsh
!include LogicLib.nsh
; augment LogicLib
!macro _FileExists2 _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	StrCpy $_LOGICLIB_TEMP "0"
	StrCmp `${_b}` `` +4 0 ;if path is not blank, continue to next check
	IfFileExists `${_b}` `0` +3 ;if path exists, continue to next check (IfFileExists returns true if this is a directory)
	IfFileExists `${_b}\*.*` +2 0 ;if path is not a directory, continue to confirm exists
	StrCpy $_LOGICLIB_TEMP "1" ;file exists
	;now we have a definitive value - the file exists or it does not
	StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
!macroend
!undef FileExists
!define FileExists `"" FileExists2`
!macro _DirExists _a _b _t _f
	!insertmacro _LOGICLIB_TEMP
	StrCpy $_LOGICLIB_TEMP "0"	
	StrCmp `${_b}` `` +3 0 ;if path is not blank, continue to next check
	IfFileExists `${_b}\*.*` 0 +2 ;if directory exists, continue to confirm exists
	StrCpy $_LOGICLIB_TEMP "1"
	StrCmp $_LOGICLIB_TEMP "1" `${_t}` `${_f}`
!macroend
!define DirExists `"" DirExists`
!include MUI2.nsh
!include nsDialogs.nsh
!include TextFunc.nsh
!include WinMessages.nsh
!include WinVer.nsh

;#######################################
;# URLs
;#######################################

; documentation URLs for utils
!define ATOMICPARSLEYDOC "http://atomicparsley.sourceforge.net/"
!define FFMPEGDOC "http://ffmpeg.org/documentation.html"
; repo URLs
!define GIPREPO "https://github.com/get-iplayer/get_iplayer"
!define INSTREPO "https://github.com/get-iplayer/get_iplayer_win32"

;#######################################
;# Variables
;#######################################

Var SMDirMain
Var SMDirHelp
Var SMDirUpdate
Var Errors
Var ErrNum
Var Results

;#######################################
;# Custom Pages
;#######################################

; disply errors
!macro ErrorsPage _un
Function ${_un}ErrorsPage
	${If} $Errors == ""
		Abort
	${EndIf}
    !insertmacro MUI_HEADER_TEXT \
		"Errors" \
		"Errors were generated by $(^Name) Setup - please read carefully"
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
	; grey out close button
	System::Call "user32::GetSystemMenu(i $HWNDPARENT, i 0) i.s"
	System::Call "user32::EnableMenuItem(i s, i 0xF060, i 1)"
	; disable close and cancel buttons
	GetDlgItem $R2 $HWNDPARENT 2
	EnableWindow $R2 0
	nsDialogs::CreateControl EDIT \
		${__NSD_Text_STYLE}|${WS_VSCROLL}|${WS_HSCROLL}|${ES_MULTILINE}|${ES_READONLY} \
		${__NSD_Text_EXSTYLE} 0 0 100% 100% \
		"NOTE: You can select the text below and copy it to a file for reference$\r$\n$\r$\n$Errors"
	Pop $1
	; set tab width
	System::Call "user32::SendMessage(i $1, i ${EM_SETTABSTOPS}, i 1, *i 16) i.s"
    nsDialogs::Show
FunctionEnd
!macroend
!insertmacro ErrorsPage ""
!insertmacro ErrorsPage "un."

!define RESULTS \
	"$(^Name) Setup attempted to clean up the previous installation for the current user \
	($UserName). If that is not the account you use with $(^Name) (e.g., you are using a \
	separate administrator account for installation), visit the wiki page below for \
	instructions on how to manually clean up the previous installation."

; display wiki cleanup info
Function onResultsClick
	Pop $0
	ExecShell "open"  "${INSTREPO}/wiki/cleanup" 
FunctionEnd

; display cleanup results
Function ResultsPage
	${If} $Results == ""
		Abort
	${EndIf}
    !insertmacro MUI_HEADER_TEXT \
		"Cleanup Results" \
		"Further steps may be required to clean up previous installation - please read carefully"
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
	; grey out close button
	System::Call "user32::GetSystemMenu(i $HWNDPARENT, i 0) i.s"
	System::Call "user32::EnableMenuItem(i s, i 0xF060, i 1)"
	; disable close and cancel buttons
	GetDlgItem $R2 $HWNDPARENT 2
	EnableWindow $R2 0
	; disable back button if no errors
	${If} $Errors == ""
		GetDlgItem $R3 $HWNDPARENT 3
		EnableWindow $R3 0
    ${EndIf}
	; for ${RESULTS} above
	${NSD_CreateLabel} 0 0 100% 40u $Results
	Pop $1
	; link to cleanup info
	${NSD_CreateLink} 0 50u 100% 10u "${INSTREPO}/wiki/cleanup"
	Pop $2
	${NSD_OnClick} $2 onResultsClick
    nsDialogs::Show
FunctionEnd


;#######################################
;# Pages
;#######################################

; disable back button if no errors or warnings
!macro DisableFinishBackButton _un
Function ${_un}DisableFinishBackButton
	${If} $Errors == ""
	${AndIf} $Results == ""
		GetDlgItem $R3 $HWNDPARENT 3
		EnableWindow $R3 0 
	${EndIf}
FunctionEnd
!macroend
!insertmacro DisableFinishBackButton ""
!insertmacro DisableFinishBackButton "un."

; show warning on cancel
!define MUI_ABORTWARNING
; icons
!define MUI_ICON get_iplayer.ico
!define MUI_UNICON get_iplayer_uninst.ico
; install pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${GIPDIR}\LICENSE.txt"
!insertmacro MUI_PAGE_INSTFILES
Page custom ErrorsPage
Page custom ResultsPage
!define MUI_FINISHPAGE_SHOWREADME ${GIPREPO}/wiki/releasenotes
!define MUI_FINISHPAGE_SHOWREADME_TEXT "View $(^Name) release notes"
!define MUI_FINISHPAGE_LINK_LOCATION ${GIPREPO}/wiki
!define MUI_FINISHPAGE_LINK "$(^Name) Documentation"
!define MUI_PAGE_CUSTOMFUNCTION_SHOW DisableFinishBackButton
!insertmacro MUI_PAGE_FINISH
; uninstall pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
UninstPage custom un.ErrorsPage
!define MUI_PAGE_CUSTOMFUNCTION_SHOW un.DisableFinishBackButton
!insertmacro MUI_UNPAGE_FINISH
; language
!insertmacro MUI_LANGUAGE "English"

;#######################################
;# Cleanup
;#######################################

; cleanup vars
Var UserName
Var SysProfileDir
Var SysOptionsFile
Var UserProfileDir
Var UserOptionsFile
Var SysOutputDir
Var UserOutputDir
Var TransferOutputDir
Var VirtualStoreDir32
Var VirtualStoreDir64
Var UserInstallDir
Var UserPluginsDir

; set up for cleanup actions
Function CleanupInit
	SetShellVarContext current
	; current user
	UserInfo::GetName
	Pop $UserName
	; profile dirs
	ExpandEnvStrings $SysProfileDir "%ALLUSERSPROFILE%\${PRODUCT}"
	StrCpy $UserProfileDir "$PROFILE\.${PRODUCT}"
	; options files
	StrCpy $SysOptionsFile "$SysProfileDir\options"
	StrCpy $UserOptionsFile "$UserProfileDir\options"
	; virtual store dirs
	StrCpy $VirtualStoreDir32 "$LOCALAPPDATA\VirtualStore\Program Files\${PRODUCT}"
	StrCpy $VirtualStoreDir64 "$LOCALAPPDATA\VirtualStore\Program Files (x86)\${PRODUCT}"
	; output dir settings
	${ConfigRead} $SysOptionsFile "output " $SysOutputDir
	${ConfigRead} $UserOptionsFile "output " $UserOutputDir
	; transfer custom output dir setting
	${If} $UserOutputDir == ""
	${AndIf} $SysOutputDir != ""
	${AndIf} $SysOutputDir != "$DESKTOP\iPlayer Recordings"
	${AndIf} ${DirExists} $UserProfileDir
		StrCpy $TransferOutputDir $SysOutputDir
	${EndIf}
	; user plugins dir
	StrCpy $UserPluginsDir "$UserProfileDir\plugins"
	; previous install location
	ReadRegStr $UserInstallDir HKCU "Software\${PRODUCT}" ""
FunctionEnd

; remove files for old helper application
!macro _RemoveHelper _name _key
	Delete "$INSTDIR\${_name}.zip"
	RMDir /r "$INSTDIR\${_name}"
	Delete "$INSTDIR\${_name}_docs.url"
	${If} $SysOptionsFile != ""
	${AndIf} ${FileExists} $SysOptionsFile
		${ConfigWrite} $SysOptionsFile "${_key} " "" $0
	${EndIf}
!macroend
!define RemoveHelper "!insertmacro _RemoveHelper"

; remove obsolete installer items
Function InstCleanup
	; remove items obsolete in 4.3+
	RMDir /r "$INSTDIR\rtmpdump-2.2d"
	RMDir /r "$INSTDIR\Downloads"
	Delete "$INSTDIR\linuxcentre.url"
	Delete "$INSTDIR\get_iplayer_setup.nsi"
	Delete "$INSTDIR\update_get_iplayer.cmd"
	Delete "$INSTDIR\get_iplayer.cgi.old"
	Delete "$INSTDIR\get_iplayer.pl.old"
	; clean up obsolete items in 2.95.0+
	; remove old batch files
	Delete "$INSTDIR\get_iplayer--pvr.bat"
	Delete "$INSTDIR\run_pvr_scheduler.bat"
	; remove old shortcuts
	Delete "$INSTDIR\get_iplayer_docs.url"
	Delete "$INSTDIR\get_iplayer_examples.url"
	Delete "$INSTDIR\get_iplayer_home.url"
	Delete "$INSTDIR\command_examples.url"
	Delete "$INSTDIR\nsis_docs.url"
	Delete "$INSTDIR\strawberry_docs.url"
	Delete "$INSTDIR\download_latest_installer.url"
	Delete "$INSTDIR\pvr_manager.url"
	; remove old registry key
	DeleteRegValue HKLM ${UNINSTKEY} "Publisher"
	; remove old version files
	Delete "$INSTDIR\get_iplayer-ver.txt"
	Delete "$INSTDIR\get_iplayer-ver-check.txt"
	; remove old config files
	Delete "$INSTDIR\get_iplayer_config.ini"
	Delete "$INSTDIR\get_iplayer_config-check.ini"
	Delete "$INSTDIR\get_iplayer-ver-check.txt"
	; remove old Perl
	RMDir /r "$INSTDIR\lib"
	RMDir /r "$INSTDIR\perl-license"
	Delete "$INSTDIR\perl.exe"
	Delete "$INSTDIR\*.dll"
	; remove old uninstaller
	Delete "$INSTDIR\Uninst.exe"
	; remove old icon
	Delete "$INSTDIR\iplayer_logo.ico"
	; remove old helpers
	${RemoveHelper} "AtomicParsley" "atomicparsley" 
	${RemoveHelper} "FFmpeg" "ffmpeg"
	${RemoveHelper} "LAME" "lame"
	${RemoveHelper} "MPlayer" "mplayer"
	${RemoveHelper} "RTMPDump" "flvstreamer"
	${RemoveHelper} "VLC" "vlc"
	; remove old settings
	${ConfigWrite} $SysOptionsFile "mmsnothread " "" $0
	${ConfigWrite} $SysOptionsFile "nopurge " "" $0
	${ConfigWrite} $SysOptionsFile "output " "" $0
	; remove obsolete sys profile dir
	${If} ${DirExists} $SysProfileDir
!ifndef TESTERRORS
		RMDir /r $SysProfileDir
!endif
		${If} ${DirExists} $SysProfileDir
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to remove obsolete system profile directory:$\r$\n$\t\
				$SysProfileDir$\r$\n\
				You must remove it manually to ensure that $(^Name) functions properly$\r$\n\
				on multi-user systems. Removal requires administrator privileges.$\r$\n\
				This action is required.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; clean up obsolete items in 3.00.0+
	; remove RTMPDump
	Delete "$INSTDIR\utils\rtmpdump.exe"
	RMDir /r "$INSTDIR\utils\licenses\rtmpdump"
	Delete "$SMDirHelp\RTMPDump Documentation.url"
FunctionEnd

; Trim
;   Removes leading & trailing whitespace from a string
; Usage:
;   Push
;   Call Trim
;   Pop
Function Trim
	Exch $R1 ; Original string
	Push $R2
Loop:
	StrCpy $R2 "$R1" 1
	StrCmp "$R2" " " TrimLeft
	StrCmp "$R2" "$\r" TrimLeft
	StrCmp "$R2" "$\n" TrimLeft
	StrCmp "$R2" "$\t" TrimLeft
	GoTo Loop2
TrimLeft:
	StrCpy $R1 "$R1" "" 1
	Goto Loop
Loop2:
	StrCpy $R2 "$R1" 1 -1
	StrCmp "$R2" " " TrimRight
	StrCmp "$R2" "$\r" TrimRight
	StrCmp "$R2" "$\n" TrimRight
	StrCmp "$R2" "$\t" TrimRight
	GoTo Done
TrimRight:
	StrCpy $R1 "$R1" -1
	Goto Loop2
Done:
	Pop $R2
	Exch $R1
FunctionEnd

; obsolete SWF URL from June 2013 debacle
!define OLDSWFURL "http://www.bbc.co.uk/emp/releases/iplayer/revisions/617463_618125_4/617463_618125_4_emp.swf"
!macro _DeleteSwfUrl201306 _key
	StrCpy $1 "$PROFILE\.get_iplayer\options"
	IfFileExists $1 0 no_options_${_key}
		StrCpy $2 "${OLDSWFURL}"
		StrCpy $3 "--swfVfy"
		${ConfigRead} $1 "${_key} " $R0
		Push $R0
		Call Trim
		Pop $R0
		${StrLoc} $4 $R0 $2 ">"
		IntCmp $4 0 ${_key}1 0
			${ConfigWrite} $1 "${_key}" "" $R1
			Goto ${_key}2
		${_key}1:
		StrCmp $R0 $3 0 ${_key}2
			${ConfigWrite} $1 "${_key}" "" $R1
		${_key}2:
	no_options_${_key}:
!macroend
!define DeleteSwfUrl201306 "!insertmacro _DeleteSwfUrl201306"

; clean up previous installation
Function UserCleanup
	SetShellVarContext current
	; virtual store (32-bit)
	${If} ${DirExists} $VirtualStoreDir32
!ifndef TESTERRORS
		RMDir /r $VirtualStoreDir32
!endif
		${If} ${DirExists} $VirtualStoreDir32
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to remove virtual store directory:$\r$\n$\t\
				$VirtualStoreDir32$\r$\n\
				You must remove it manually for $(^Name) to function properly.$\r$\n\
				This action is required.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; virtual store (64-bit)
	${If} ${DirExists} $VirtualStoreDir64
!ifndef TESTERRORS
		RMDir /r $VirtualStoreDir64
!endif
		${If} ${DirExists} $VirtualStoreDir64
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to remove virtual store directory:$\r$\n$\t\
				$VirtualStoreDir64$\r$\n\
				You must remove it manually for $(^Name) to function properly.$\r$\n\
				This action is required.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; transfer custom output dir setting
	${If} $TransferOutputDir != ""
		ClearErrors
!ifndef TESTERRORS
		ExecWait "$\"$INSTDIR\get_iplayer.cmd$\" --prefs-add --output=$\"$TransferOutputDir$\"" $0
!else
		SetErrors
!endif
		${If} ${Errors}
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to transfer previous output setting to user preferences.$\r$\n\
				You can update your preferences with the following command:$\r$\n$\t\
				get_iplayer --prefs-add --output=$\"$TransferOutputDir$\"$\r$\n\
				This action is not required.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; user plugins dir
	${If} ${DirExists} $UserPluginsDir
!ifndef TESTERRORS
		Delete "$UserPluginsDir\localfiles.plugin"
		Delete "$UserPluginsDir\localfiles.plugin.old"
		Delete "$UserPluginsDir\plugin.template"
		Delete "$UserPluginsDir\podcast.plugin"
		Delete "$UserPluginsDir\podcast.plugin.old"
		RMDir $UserPluginsDir
!endif
		${If} ${DirExists} $UserPluginsDir
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to remove obsolete user plugins directory:$\r$\n$\t\
				$UserPluginsDir$\r$\n\
				It may contain files not installed by $(^Name) Setup. Remove manually.$\r$\n\
				This action is not required, but is strongly recommended.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; previous install location
	${If} $UserInstallDir != ""
		; install dir reg key
		ClearErrors
!ifndef TESTERRORS
		DeleteRegKey HKCU "Software\get_iplayer"
!else
		SetErrors
!endif
		${If} ${Errors}
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to delete obsolete registry key:$\r$\n$\t\
				HKCU\Software\get_iplayer$\r$\n\
				Remove manually while logged in to the account you use with $(^Name).$\r$\n\
				This action is not required.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
		; install dir
		${If} $UserInstallDir != $INSTDIR
		${AndIf} ${DirExists} $UserInstallDir
!ifndef TESTERRORS
			; RMDir /r $UserInstallDir
!endif
			${If} ${DirExists} $UserInstallDir
				StrCpy $Errors "$Errors\
					$ErrNum. Detected previous installation directory:$\r$\n$\t\
					$UserInstallDir$\r$\n\
					Remove manually. This action is not required.$\r$\n$\r$\n"
				IntOp $ErrNum $ErrNum + 1
			${EndIf}
		${EndIf}
	${EndIf}
	; start menu folder
	StrCpy $1 "$SMPROGRAMS\get_iplayer"
	${If} ${DirExists} $1
!ifndef TESTERRORS
		RMDir /r $1
!endif
		${If} ${DirExists} $1
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to remove obsolete Start Menu folder:$\r$\n$\t\
				$1$\r$\n\
				Remove manually. This action is not required.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; start menu shortcut
	StrCpy $2 "$SMPROGRAMS\VLC Media Player.lnk"
	${If} ${FileExists} $2
!ifndef TESTERRORS
		Delete $2
!endif
		${If} ${FileExists} $2
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to remove obsolete Start Menu shortcut:$\r$\n$\t\
				$2$\r$\n\
				Remove manually. This action is not required.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; June 2013 SWF URL debacle
	${If} ${FileExists} $UserOptionsFile
!ifndef TESTERRORS
		${DeleteSwfUrl201306} "rtmptvopts"
		${DeleteSwfUrl201306} "rtmpradioopts"
		${DeleteSwfUrl201306} "rtmplivetvopts"
		${DeleteSwfUrl201306} "rtmpliveradioopts"
!endif
		${ConfigRead} $UserOptionsFile "rtmptvopts " $1
		${ConfigRead} $UserOptionsFile "rtmpradioopts " $2
		${ConfigRead} $UserOptionsFile "rtmplivetvopts " $3
		${ConfigRead} $UserOptionsFile "rtmpliveradioopts " $4
		${StrLoc} $R1 $1 "${OLDSWFURL}" ">"
		${StrLoc} $R2 $2 "${OLDSWFURL}" ">"
		${StrLoc} $R3 $3 "${OLDSWFURL}" ">"
		${StrLoc} $R4 $4 "${OLDSWFURL}" ">"
		${If} $R1 <> 0
			StrCpy $R9 "$R9$\trtmptvopts $1$\r$\n"
		${EndIf}
		${If} $R2 <> 0
			StrCpy $R9 "$R9$\trtmpradioopts $2$\r$\n"
		${EndIf}
		${If} $R3 <> 0
			StrCpy $R9 "$R9$\trtmplivetvopts $3$\r$\n"
		${EndIf}
		${If} $R4 <> 0
			StrCpy $R9 "$R9$\trtmpliveradioopts $4$\r$\n"
		${EndIf}
		${If} $R9 != ""
			StrCpy $Errors "$Errors\
				$ErrNum. Failed to remove options containing obsolete SWF URL:$\r$\n\
				$R9\
				from user options file:$\r$\n$\t\
				$UserOptionsFile$\r$\n\
				Edit file and remove options manually. This action is not required, but you may$\r$\n\
				encounter problems in a future release if you do not delete the obsolete entries.$\r$\n$\r$\n"
			IntOp $ErrNum $ErrNum + 1
		${EndIf}
	${EndIf}
	; set message for results page
	StrCpy $Results "${RESULTS}"
FunctionEnd

;#######################################
;# Callbacks
;#######################################

!macro _InitSMDirs
	StrCpy $SMDirMain "$SMPROGRAMS\${PRODUCT}"
	StrCpy $SMDirHelp "$SMDirMain\Help"
	StrCpy $SMDirUpdate "$SMDirMain\Update"
!macroend
!define InitSMDirs "!insertmacro _InitSMDirs"

Function .onInit
	${IfNot} ${AtLeastWin7}
		MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 \
			"NOTE:$\r$\n$\r$\n \
			- Windows 7 is the minimum version supported by the get_iplayer developer$\r$\n \
			- The bundled version of ffmpeg does not work on earlier Windows versions$\r$\n \
			- You must replace the bundled version of ffmpeg in order to convert output files to MP4 and add metadata tags$\r$\n$\r$\n \
			Do you wish to proceed with the installation?" \
			IDYES proceed
			Quit
		proceed:
	${EndIf}
	SetShellVarContext all
	${InitSMDirs}
	StrCpy $ErrNum 1
FunctionEnd

Function un.onInit
	SetShellVarContext all
	${InitSMDirs}
	StrCpy $ErrNum 1
FunctionEnd

;#######################################
;# Sections
;#######################################

Section "-get_iplayer"
	SetOutPath $INSTDIR
	; scripts
	File /oname=get_iplayer.pl "${GIPDIR}\get_iplayer"
	File "${GIPDIR}\get_iplayer.cgi"
	File "${GIPDIR}\LICENSE.txt"
	; batch files
	File get_iplayer.cgi.cmd
	File get_iplayer.cmd
	File pvr_manager.cmd
	File run_pvr_scheduler.cmd
	; start menu
	File ${MUI_ICON}
	CreateDirectory "$SMDirMain"
	CreateShortCut "$SMDirMain\get_iplayer.lnk" "$SYSDIR\cmd.exe" \
		"/k get_iplayer.cmd --search dontshowanymatches && get_iplayer.cmd --help" "$INSTDIR\${MUI_ICON}"
	ShellLink::SetShortCutWorkingDirectory "$SMDirMain\get_iplayer.lnk" "%HOMEDRIVE%%HOMEPATH%"
	CreateShortCut "$SMDirMain\Web PVR Manager.lnk" "$SYSDIR\cmd.exe" \
		"/c pvr_manager.cmd" "$INSTDIR\${MUI_ICON}"
	ShellLink::SetShortCutWorkingDirectory "$SMDirMain\Web PVR Manager.lnk" "%HOMEDRIVE%%HOMEPATH%"
	CreateShortCut "$SMDirMain\Run PVR Scheduler.lnk" "$SYSDIR\cmd.exe" \
		"/k run_pvr_scheduler.cmd" "$INSTDIR\${MUI_ICON}"
	ShellLink::SetShortCutWorkingDirectory "$SMDirMain\Run PVR Scheduler.lnk" "%HOMEDRIVE%%HOMEPATH%"
	; help
	CreateDirectory "$SMDirHelp"
	WriteINIStr "$SMDirHelp\get_iplayer Documentation.url" "InternetShortcut" "URL" "${GIPREPO}/wiki"
	WriteINIStr "$SMDirHelp\get_iplayer Examples.url" "InternetShortcut" "URL" "${GIPREPO}/wiki/documentation"
	; update
	CreateDirectory "$SMDirUpdate"
	WriteINIStr "$SMDirUpdate\Check for Update.url" "InternetShortcut" "URL" "${INSTREPO}/releases"
!ifndef NOPERL
	; clear Perl before (re)install
	RMDir /r "$INSTDIR\perl"
	; Perl
	SetOutPath "$INSTDIR\perl"
	File /r "${PERLDIR}\lib"
	File /r "${PERLDIR}\licenses"
	File "${PERLDIR}\*.dll"
	File "${PERLDIR}\perl.exe"
	SetOutPath $INSTDIR
	WriteINIStr "$SMDirHelp\Strawberry Perl Home.url" "InternetShortcut" "URL" "http://strawberryperl.com/"
!endif
!ifndef NOUTILS
	; utils
	SetOutPath "$INSTDIR\utils"
	File "${ATOMICPARSLEYDIR}\AtomicParsley.exe"
	File "${FFMPEGDIR}\bin\ffmpeg.exe"
	File sources.txt
	SetOutPath "$INSTDIR\utils\licenses\atomicparsley"
	File "${ATOMICPARSLEYDIR}\COPYING"
	SetOutPath "$INSTDIR\utils\licenses\ffmpeg"
	File "${FFMPEGDIR}\README.txt"
	File "${FFMPEGDIR}\licenses\*.*"
	SetOutPath $INSTDIR
	WriteINIStr "$SMDirHelp\AtomicParsley Documentation.url" "InternetShortcut" "URL" "${ATOMICPARSLEYDOC}"
	WriteINIStr "$SMDirHelp\FFmpeg Documentation.url" "InternetShortcut" "URL" "${FFMPEGDOC}"
!endif
	; append install dir to system path
	ClearErrors
!ifndef TESTERRORS
	${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR"
!else
	SetErrors
!endif
	${If} ${Errors}
		StrCpy $Errors "$Errors\
			$ErrNum. Failed to amend system path. You must manually add the following directory to the$\r$\n\
			system PATH environment variable:$\r$\n$\t\
			$INSTDIR$\r$\n\
			This error may occur if adding the get_iplayer installation directory to the system$\r$\n\
			PATH environment variable would increase its total length to >= ${NSIS_MAX_STRLEN} characters.$\r$\n\
			This action is required$\r$\n$\r$\n"
		IntOp $ErrNum $ErrNum + 1
	${EndIf}
SectionEnd

Section "-Uninstaller"
	; create uninstaller
	WriteUninstaller "$INSTDIR\uninstall.exe"
	CreateShortCut "$SMDirMain\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
	; add uninstall info to registry
	WriteRegStr HKLM ${UNINSTKEY} "DisplayIcon" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM ${UNINSTKEY} "DisplayName" "$(^Name)"
	WriteRegStr HKLM ${UNINSTKEY} "DisplayVersion" "${WINVERSION}"
	WriteRegStr HKLM ${UNINSTKEY} "UninstallString" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM ${UNINSTKEY} "URLInfoAbout" "${INSTREPO}"
	WriteRegStr HKLM ${UNINSTKEY} "URLUpdateInfo" "${INSTREPO}/releases"
SectionEnd

Section "-Cleanup"
	; clean up previous installation
	Call CleanupInit
	Call InstCleanup
	Call UserCleanup
SectionEnd

Section "Uninstall"
	; scripts
	Delete "$INSTDIR\get_iplayer.cgi"
	Delete "$INSTDIR\get_iplayer.pl"
	Delete "$INSTDIR\LICENSE.txt"
	; batch files
	Delete "$INSTDIR\get_iplayer.cgi.cmd"
	Delete "$INSTDIR\get_iplayer.cmd"
	Delete "$INSTDIR\pvr_manager.cmd"
	Delete "$INSTDIR\run_pvr_scheduler.cmd"
	; start menu
	Delete "$INSTDIR\${MUI_ICON}"
	Delete "$SMDirMain\get_iplayer.lnk"
	Delete "$SMDirMain\Web PVR Manager.lnk"
	Delete "$SMDirMain\Run PVR Scheduler.lnk"
	; help
	Delete "$SMDirHelp\get_iplayer Documentation.url"
	Delete "$SMDirHelp\get_iplayer Examples.url"
	; update
	Delete "$SMDirUpdate\Check for Update.url"
!ifndef NOPERL
	; Perl
	RMDir /r "$INSTDIR\perl"
	Delete "$SMDirHelp\Strawberry Perl Home.url"
!endif
!ifndef NOUTILS
	; utils
	RMDir /r "$INSTDIR\utils"
	Delete "$SMDirHelp\AtomicParsley Documentation.url"
	Delete "$SMDirHelp\FFmpeg Documentation.url"
!endif
	; start menu sub-folders
	RMDir "$SMDirHelp"
	RMDir "$SMDirUpdate"
	; start menu folder
	Delete "$SMDirMain\Uninstall.lnk"
	RMDir "$SMDirMain"
	; remove uninstall info from registry
	DeleteRegKey HKLM "${UNINSTKEY}"
	; remove uninstaller
	Delete "$INSTDIR\uninstall.exe"
	; remove install dir
	RMDir $INSTDIR
	; remove install dir from system path
	ClearErrors
!ifndef TESTERRORS
	${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR"
!else
	SetErrors
!endif
	${If} ${Errors}
		StrCpy $Errors "$Errors\
			$ErrNum. Failed to amend system path. You must manually remove the following directory$\r$\n\
			from the system PATH environment variable:$\r$\n$\t\
			$INSTDIR$\r$\n\
			This action is required$\r$\n$\r$\n"
		IntOp $ErrNum $ErrNum + 1
	${EndIf}
SectionEnd
