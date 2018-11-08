
;!Highly recommended for improved overall performance and responsiveness of the GUI effects etc.! (after compiling):
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /rm /pe

;YOU NEED TO EXCLUDE FOLLOWING FUNCTIONS FROM AU3STRIPPER, OTHERWISE IT WON'T WORK:
#Au3Stripper_Ignore_Funcs=_iHoverOn,_iHoverOff,_iFullscreenToggleBtn,_cHvr_CSCP_X64,_cHvr_CSCP_X86,_iControlDelete
;Please not that Au3Stripper will show errors. You can ignore them as long as you use the above Au3Stripper_Ignore_Funcs parameters.

;Required if you want High DPI scaling enabled. (Also requries _Metro_EnableHighDPIScaling())
#AutoIt3Wrapper_Res_HiDpi=y
; ===============================================================================================================================

#include "MetroGUI-UDF\MetroGUI_UDF.au3"
#include "MetroGUI-UDF\_GUIDisable.au3" ; For dim effects when msgbox is displayed
#include <GUIConstants.au3>

#include <Constants.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
Opt('MustDeclareVars', 1)

#RequireAdmin


	Global $ExternalDriveLocation = "D:\ProgramData\chocolatey"


;=======================================================================Creating the GUI===============================================================================
;Enable high DPI support: Detects the users DPI settings and resizes GUI and all controls to look perfectly sharp.
_Metro_EnableHighDPIScaling() ; Note: Requries "#AutoIt3Wrapper_Res_HiDpi=y" for compiling. To see visible changes without compiling, you have to disable dpi scaling in compatibility settings of Autoit3.exe

;Set Theme
_SetTheme("DarkTeal") ;See MetroThemes.au3 for selectable themes or to add more

;Create resizable Metro GUI
$Form1 = _Metro_CreateGUI("Auto Install", 500, 300, -1, -1, True)


	Local $Form2 = GUICreate("Auto-Install", 405, 294, 334, 476,$WS_MINIMIZEBOX+$WS_SIZEBOX,$WS_EX_TOPMOST)
	GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")

	Global $BoxID = GUICtrlCreateEdit("", 3, 5, 400, 175)
	Local $iStartButton = GUICtrlCreateButton("Start", 100, 195, 200, 75, $WS_MINIMIZEBOX+$WS_SIZEBOX)
	GUICtrlSetOnEvent($iStartButton, "StartButton")
	GUISetState(@SW_SHOW, $Form2)

	While 1
		Sleep(100)
	WEnd




Func _Main()

	;CreateSymbolicLink()
	;InstallChocolatey()
	;UpgradeChocolatey()


EndFunc

Func StartButton()
		_Main()
EndFunc

Func CLOSEButton()
    ; Note: At this point @GUI_CtrlId would equal $GUI_EVENT_CLOSE,
    ; and @GUI_WinHandle would equal $hMainGUI
   ;MsgBox($MB_OK, "GUI Event", "You selected CLOSE! Exiting...")
    Exit
EndFunc   ;==>CLOSEButton

Func CreateSymbolicLink()

	Local $PathToTheSymbolicLink
	Local $DirectoryLink = 1
	Local $sChocInstallLocation = "C:\ProgramData\chocolatey"

	$PathToTheSymbolicLink = _SymLink($ExternalDriveLocation, $sChocInstallLocation, $DirectoryLink)
	;On Success: Returns the path to the created SymLink.
	If IsNumber($PathToTheSymbolicLink) Then
		;-------------------------------------------------
		;Exit Progran if the Symbolic Link DLL Call Failed
		;-------------------------------------------------
		If $PathToTheSymbolicLink == 1 Then
			MsgBox(0, "Exiting Program", "Symbolic Link DLL Call Failed...")
			Exit
		ElseIf $PathToTheSymbolicLink == 0 Then
			MsgBox(0, "Error", "Symbolic Link Already Exists")
		EndIf

	EndIf

EndFunc   ;==>CreateSymbolicLink
Func InstallChocolatey()
	Local $InstallSuccessfull = "Chocolatey (choco.exe) is now ready."
	Local $OverwriteExistingFiles = 1

	FileInstall("InstallChocolatey.bat", @TempDir & "\InstallChocolatey.bat", $OverwriteExistingFiles)
	;Run(@TempDir & "\InstallChocolatey.bat", @ScriptDir, @SW_SHOW)

	Local $TheText = GetCMDText(@TempDir & "\InstallChocolatey.bat",@ScriptDir)
	If StringInStr($TheText, $InstallSuccessfull) Then
			ConsoleWrite("Chocolatey (choco.exe) is now ready." & @CRLF)
	EndIf

EndFunc   ;==>InstallChocolatey


Func GetCMDText($sTheDosCommand, $sWorkingDir = "")

	Local $DOS, $Message, $Message2, $EntireText

	$DOS = Run(@ComSpec & " /k " & $sTheDosCommand, $sWorkingDir, @SW_SHOW, $STDERR_CHILD + $STDOUT_CHILD)
	;$Message2 = StdoutRead($DOS)
	Do
		$Message &= StdoutRead($DOS)
		$EntireText &= $Message
		If @error Then ExitLoop
		If Not $Message = "" Then
			GUICtrlSetData($BoxID, $Message & @CRLF, 1)
		EndIf
		$Message = ""

	Until 1 < 1

	ProcessWaitClose($DOS)
	ConsoleWrite("--------------------------------------------")
	ConsoleWrite(@CRLF & "EntireText: " & $EntireText & @CRLF)
	ConsoleWrite("--------------------------------------------")

	Return $EntireText

EndFunc   ;==>GetCMDText
Func UpgradeChocolatey()

	Local $sLatestVersion = "is the latest version available based on your source(s)."
	Local $sUpgradedVersion = "Chocolatey upgraded 1/1 packages."

	Local $TheText = GetCMDText("choco upgrade chocolatey")


	If StringInStr($TheText, $sLatestVersion) Then
		;----------------------------------------------
		;Running the most recent version of Chocolatey
		;---------------------------------------------
		ConsoleWrite("Running the most recent version of Chocolatey." & @CRLF)
	ElseIf StringInStr($TheText, $sUpgradedVersion) Then
		ConsoleWrite("Chocolatey upgraded 1/1 packages." & @CRLF)
	Else
		;Somthing Went Wrong
		MsgBox(0, "Did Not Install Correctly", "choco upgrade chocolatey: " & $TheText)
		;Exit
	EndIf

EndFunc   ;==>InsatllChocolatey
Func _SymLink($qLink, $qTarget, $qIsDirectoryLink = 0)

	;=======================================================================================
	; Function Name:    _SymLink
	; Description:      Creates an NTFS Symbolic Link at the specified location
	;                   to another specified location.
	;
	; Parameter(s):     $qLink              = The file or directory you want to create.
	;                   $qTarget            = The location $qLink should link to.
	;                   $qIsDirectoryLink   = 0 for a FILE symlink (default).
	;                                         1 for a DIRECTORY symlink.
	;
	; Syntax:           _SymLink( $qLink, $qTarget, [$qIsDirectoryLink = 0] )
	;
	; Return Value(s):  On Success: Returns the path to the created SymLink.
	;
	;                   On Failure: 0 and set @Error:
	;
	;                               1 = DLLCall failed, @extended for more info
	;                               2 = $qLink already exists!
	;
	; Notes:            To remove a Symbolic link, just delete it as you would any
	;                   file or directory.
	;
	; Author(s):        Andrew Bobulsky (RulerOf@{Google's-infamous-mail-service}.com)
	;
	; Other info:       http://www.informit.com/guides/content.aspx?g=dotnet&seqNum=762
	; MSDN:             http://msdn.microsoft.com/en-us/library/aa363866(VS.85).aspx
	;=======================================================================================

	If FileExists($qLink) Then
		SetError(2)
		MsgBox(0, "Error", "Symbolic Link Already Exists...")
		ConsoleWrite("Symbolic Link Already Exists..." & @CRLF)
		Return 0
	EndIf

	DllCall("kernel32.dll", "BOOLEAN", "CreateSymbolicLink", "str", $qLink, "str", $qTarget, "DWORD", Hex($qIsDirectoryLink))
	If @error Then
		SetError(1, @extended, 0)
		MsgBox(0, "Error", "DLLCall failed, @extended for more info: " & @extended)
		ConsoleWrite("DLLCall failed, @extended for more info: " & @extended)
		Return 1
	EndIf

	Return $qLink

EndFunc   ;==>_SymLink















