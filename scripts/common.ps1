$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot

function Invoke-RepoPython {
    param([Parameter(ValueFromRemainingArguments=$true)][string[]]$PythonArgs)
    $candidates = @(
        (Join-Path $env:USERPROFILE '.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe'),
        'python', 'python3'
    )
    foreach ($candidate in $candidates) {
        $command = Get-Command $candidate -ErrorAction SilentlyContinue
        if ($command) {
            & $command.Source -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 1)' 2>$null
            if ($LASTEXITCODE -eq 0) {
                & $command.Source @PythonArgs
                if ($LASTEXITCODE -ne 0) { throw "Python command failed (exit $LASTEXITCODE). See the report above." }
                return
            }
        }
    }
    throw 'Python 3.10+ is required. Install Python from https://www.python.org/downloads/ and reopen the terminal.'
}

function Assert-GitSuccess {
    if ($LASTEXITCODE -ne 0) { throw "Git failed (exit $LASTEXITCODE). No next step was performed." }
}
