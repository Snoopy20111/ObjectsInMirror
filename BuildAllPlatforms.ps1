##############################################
### Script to automate Godot Build process ###
###   for Objects In Mirror with Godot 4   ###
##############################################

# Needs Godot to be open, from the path set below
# Also needs to be run on my own machine. I'm sure with some more
# farting around I can make it figure out where it's located, or
# potentially ask where certain things are and save that info

Set-Alias godot "C:\Program Files\Godot\Godot_v4.2.1-stable_win64\Godot.exe"
$RepoPath = "C:\Users\snoop\Documents\GitHub\ObjectsInMirror"
$BuildDate = Get-Date -Format "yyyy.MM.dd.HH.mm.ss"
$OIMVersionNum = "v0.1." + $BuildDate

#Make the directories we'll be building to shortly
New-Item -ItemType Directory -Path "$RepoPath\Builds\$OIMVersionNum\Windows_Release\"
New-Item -ItemType Directory -Path "$RepoPath\Builds\$OIMVersionNum\Windows_Debug\"
New-Item -ItemType Directory -Path "$RepoPath\Builds\$OIMVersionNum\Linux_Release\"
New-Item -ItemType Directory -Path "$RepoPath\Builds\$OIMVersionNum\Linux_Debug\"

#Actually begin building

# Note each command pipes responses to "Out-Null." This makes each process wait for
# the previous to finish and close Godot.exe before running, but also removes all
# debug output from the PowerShell window, making errors harder to catch.

#Windows Release build, x86_64
godot --headless --path "$RepoPath\GodotProj" --export-release "Windows-Build" "..\Builds\$OIMVersionNum\Windows_Release\ObjectsInMirror.exe" | Out-Default
#Windows Debug build, x86_64
godot --headless --path "$RepoPath\GodotProj" --export-debug "Windows-Build" "..\Builds\$OIMVersionNum\Windows_Debug\ObjectsInMirror.exe" | Out-Default
#Linux Release build, x86_64
godot --headless --path "$RepoPath\GodotProj" --export-release "Linux-Build" "..\Builds\$OIMVersionNum\Linux_Release\ObjectsInMirror.x86_64" | Out-Default
#Linux Release build, x86_64
godot --headless --path "$RepoPath\GodotProj" --export-debug "Linux-Build" "..\Builds\$OIMVersionNum\Linux_Debug\ObjectsInMirror.x86_64" | Out-Default