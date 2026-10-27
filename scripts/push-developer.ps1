param([Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Message)
. "$PSScriptRoot/common.ps1"
Set-Location $RepoRoot
$branch = (& git branch --show-current).Trim()
Assert-GitSuccess
if ($branch -ne 'developer') { throw 'Switch to developer before committing/pushing: git switch developer' }
& git add --all
Assert-GitSuccess
& git diff --cached --quiet
if ($LASTEXITCODE -eq 1) {
    & git commit -m $Message
    Assert-GitSuccess
} elseif ($LASTEXITCODE -ne 0) { throw 'Cannot inspect staging area' }
# pre-push checks the exact HEAD with a clean working tree, then makes a new report.
& git push -u origin developer
Assert-GitSuccess
Write-Host 'Pushed to developer. main is waiting for a Pull Request, passing checks and your GitHub approval.'
