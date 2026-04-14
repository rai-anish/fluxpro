Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

Dim winFolder
winFolder = objFSO.GetParentFolderName(WScript.ScriptFullName)

Dim wslPath
wslPath = Trim(objShell.Exec("cmd.exe /c wsl wslpath """ & winFolder & """").StdOut.ReadAll())

Dim wslUser
wslUser = Trim(objShell.Exec("cmd.exe /c wsl whoami").StdOut.ReadAll())

WScript.Sleep 15000

Dim strCommand
strCommand = "wsl.exe -u " & wslUser & " /bin/bash -lc ""cd '" & wslPath & "' && ./Flux/start_flux.sh >> /tmp/fluxpro-launch.log 2>&1"""

objShell.Run strCommand, 0, False

Set objFSO = Nothing
Set objShell = Nothing

