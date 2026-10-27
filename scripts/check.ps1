param([switch]$Legacy)
. "$PSScriptRoot/common.ps1"
Set-Location $RepoRoot
Invoke-RepoPython "$PSScriptRoot/bootstrap.py"
if ($Legacy) { Invoke-RepoPython "$PSScriptRoot/validate.py" --legacy }
else { Invoke-RepoPython "$PSScriptRoot/validate.py" }
