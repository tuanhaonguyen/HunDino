. "$PSScriptRoot/common.ps1"
Set-Location $RepoRoot

# Preserve an accidentally initialized, empty nested repo instead of deleting it.
$nestedGit = Join-Path $RepoRoot 'HunDino/.git'
if (Test-Path -LiteralPath $nestedGit -PathType Container) {
    $commitCount = & git --git-dir=$nestedGit rev-list --all --count
    Assert-GitSuccess
    if ([int]$commitCount -gt 0) { throw 'HunDino/.git has commits. Resolve the nested repository manually before setup.' }
    $remotes = & git --git-dir=$nestedGit remote
    if ($remotes) { throw 'HunDino/.git has remotes. Resolve the nested repository manually before setup.' }
    $parentGit = (& git rev-parse --absolute-git-dir).Trim()
    Assert-GitSuccess
    $archiveParent = Join-Path $parentGit 'archived-nested'
    New-Item -ItemType Directory -Path $archiveParent -Force | Out-Null
    $archive = Join-Path $archiveParent ('HunDino-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff') + '.git')
    $resolvedNested = (Resolve-Path -LiteralPath $nestedGit).Path
    if ($resolvedNested -ne (Join-Path $RepoRoot 'HunDino\.git')) { throw 'Unexpected nested repository path' }
    Move-Item -LiteralPath $resolvedNested -Destination $archive
    Write-Host "Archived empty nested repo: $archive"
}

Invoke-RepoPython "$PSScriptRoot/bootstrap.py"
& git config --local core.hooksPath .githooks
Assert-GitSuccess
& git config --local push.default simple
Assert-GitSuccess
& git config --local push.autoSetupRemote true
Assert-GitSuccess
& git config --local pull.ff only
Assert-GitSuccess
& git config --local remote.origin.push refs/heads/developer:refs/heads/developer
Assert-GitSuccess
& git config --local branch.developer.pushRemote origin
Assert-GitSuccess
& git fetch origin
Assert-GitSuccess
$branch = (& git branch --show-current).Trim()
if ($branch -ne 'developer') {
    & git show-ref --verify --quiet refs/heads/developer
    if ($LASTEXITCODE -eq 0) { & git switch developer }
    else { & git switch --track origin/developer }
    Assert-GitSuccess
}
Write-Host 'Ready: developer -> checks/report -> push -> PR -> owner approval -> main.'
