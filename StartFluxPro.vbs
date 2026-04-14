Set objShell = WScript.CreateObject("WScript.Shell")
Set objFSO   = WScript.CreateObject("Scripting.FileSystemObject")

' ── Resolve the script's own Windows drive path ────────────────────────────
' Strip the filename so we get the folder the .vbs lives in
Dim winPath
winPath = objFSO.GetParentFolderName(WScript.ScriptFullName)

' Convert Windows path → WSL path via `wsl wslpath`
' e.g.  C:\Users\anish\projects\FluxPro  →  /home/anish/projects/FluxPro
Dim wsPathCmd
wsPathCmd = "cmd.exe /c wsl wslpath """ & winPath & """"

Dim wslPath
wslPath = Trim(objShell.Exec(wsPathCmd).StdOut.ReadAll())

' ── Detect the default WSL username via `wsl whoami` ───────────────────────
Dim wslUser
wslUser = Trim(objShell.Exec("cmd.exe /c wsl whoami").StdOut.ReadAll())

' ── Allow WSLg / Windows Desktop to stabilise before launching ─────────────
WScript.Sleep 1000

' ── Build and run the launch command ───────────────────────────────────────
' -l = login shell (loads ~/.bashrc, ~/.profile so PATH is fully populated)
' || read = keeps window open on failure so you can see the error
Dim strCommand
strCommand = "wsl.exe -u " & wslUser & " -e /bin/bash -l -c """ & _
    "cd " & wslPath & " && " & _
    "./Flux/start_flux.sh || " & _
    "read -rp 'FAILED — press Enter to close'"""

' Window style 1 = visible (change to 0 once stable, to launch silently)
objShell.Run strCommand, 1, False

Set objFSO   = Nothing
Set objShell = Nothing