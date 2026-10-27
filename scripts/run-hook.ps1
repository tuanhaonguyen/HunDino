param([string]$RemoteName, [string]$RemoteUrl)
. "$PSScriptRoot/common.ps1"
# Keep Git's stdin ref-update protocol intact through the PowerShell bridge.
$updates = [Console]::In.ReadToEnd()
$candidates = @((Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'), 'python', 'python3')
foreach ($candidate in $candidates) {
    $command = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($command) {
        & $command.Source -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>$null
        if ($LASTEXITCODE -eq 0) {
            $updates | & $command.Source "$PSScriptRoot/pre_push.py" $RemoteName $RemoteUrl
            exit $LASTEXITCODE
        }
    }
}
Write-Error 'Python 3.10+ is required. Run scripts/setup.ps1.'
exit 1
