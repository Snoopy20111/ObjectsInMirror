##############################################
### Script to automate Godot Build process ###
###   for Objects In Mirror with Godot 4   ###
##############################################

# Needs Godot to be open, from the path set below
# Change this for your version / naming of Godot!
$GodotPath = "C:\Program Files\Godot\Godot_v4.2.1-stable_win64\Godot.exe"
Set-Alias godot $GodotPath
$BuildDate = Get-Date -Format "yyyy.MM.dd.HH.mm.ss"
$OIMVersionNum = "v0.1." + $BuildDate

if ((Test-Path (Resolve-Path $GodotPath)) -eq $false) {
	Write-Host "Godot not found at the provided location: $GodotPath"
	Write-Host "Make sure to edit the path on Line 8 of this script to point to your Godot installation!"
	Read-Host -Prompt "Press Enter to exit"
	return
}

#if (!(Get-Process godot) {
#	Write-Host "Godot not currently running!"
#	Write-Host "Please open the Objects In Mirror project before running this script, otherwise sometimes the build commands won't work properly."
#	Read-Host -Prompt "Press Enter to exit"
#}

#Make the directories we'll be building to shortly
New-Item -ItemType Directory -Path ".\Builds\$OIMVersionNum\Windows_Release\"
New-Item -ItemType Directory -Path ".\Builds\$OIMVersionNum\Windows_Debug\"
New-Item -ItemType Directory -Path ".\Builds\$OIMVersionNum\Linux_Release\"
New-Item -ItemType Directory -Path ".\Builds\$OIMVersionNum\Linux_Debug\"

#Actually begin building

# Note each command pipes responses to "Out-Default." Piping makes each process wait
# for the previous to finish and close Godot.exe before running, but Out-Default
# still gives us that debug spew in the PowerShell window.

#Windows Release build, x86_64
godot --headless --path ".\GodotProj" --export-release "Windows-Build" "..\Builds\$OIMVersionNum\Windows_Release\ObjectsInMirror.exe" | Out-Default
#Windows Debug build, x86_64
godot --headless --path ".\GodotProj" --export-debug "Windows-Build" "..\Builds\$OIMVersionNum\Windows_Debug\ObjectsInMirror.exe" | Out-Default
#Linux Release build, x86_64
godot --headless --path ".\GodotProj" --export-release "Linux-Build" "..\Builds\$OIMVersionNum\Linux_Release\ObjectsInMirror.x86_64" | Out-Default
#Linux Release build, x86_64
godot --headless --path ".\GodotProj" --export-debug "Linux-Build" "..\Builds\$OIMVersionNum\Linux_Debug\ObjectsInMirror.x86_64" | Out-Default

Write-Host "Builds completed."
Read-Host -Prompt "Press Enter to exit the Build script"