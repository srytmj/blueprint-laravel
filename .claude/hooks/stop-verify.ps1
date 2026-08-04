# Stop hook.
# Runs typecheck/build/test for whatever stack lives in code/, if any changed.
# Exit 2 = verification failed, stderr tail is fed back to Claude to self-correct.
# Exit 0 = nothing to verify, or verification passed.

$ErrorActionPreference = 'SilentlyContinue'
Set-Location -Path (git rev-parse --show-toplevel 2>$null)

$changed = git diff --name-only HEAD -- code/ 2>$null
$changedUntracked = git ls-files --others --exclude-standard -- code/ 2>$null
if (-not $changed -and -not $changedUntracked) {
    exit 0
}

if (-not (Test-Path 'code')) {
    exit 0
}

Push-Location 'code'

$failures = @()

function Run-Step($label, $cmd) {
    $output = & cmd /c "$cmd 2>&1"
    if ($LASTEXITCODE -ne 0) {
        $script:failures += "[$label] command: $cmd`n" + ($output | Select-Object -Last 40 | Out-String)
    }
}

if (Test-Path 'package.json') {
    $pkg = Get-Content 'package.json' -Raw | ConvertFrom-Json
    $scripts = $pkg.scripts
    if ($scripts) {
        if ($scripts.typecheck) { Run-Step 'typecheck' 'npm run typecheck' }
        if ($scripts.build)     { Run-Step 'build'     'npm run build' }
        if ($scripts.test)      { Run-Step 'test'      'npm test --silent' }
    }
} elseif (Test-Path 'composer.json') {
    if (Test-Path 'vendor/bin/phpstan') { Run-Step 'typecheck' 'vendor\bin\phpstan analyse' }
    if (Test-Path 'vendor/bin/phpunit') { Run-Step 'test' 'vendor\bin\phpunit' }
} elseif (Test-Path 'go.mod') {
    Run-Step 'build' 'go build ./...'
    Run-Step 'test'  'go test ./...'
} elseif (Test-Path 'Cargo.toml') {
    Run-Step 'build' 'cargo build'
    Run-Step 'test'  'cargo test'
} elseif ((Test-Path 'pyproject.toml') -or (Test-Path 'requirements.txt')) {
    if (Get-Command pytest -ErrorAction SilentlyContinue) { Run-Step 'test' 'pytest -q' }
} elseif (Test-Path 'Makefile') {
    Run-Step 'verify' 'make test'
}

Pop-Location

if ($failures.Count -gt 0) {
    [Console]::Error.WriteLine("stop-verify: verification failed`n" + ($failures -join "`n---`n"))
    exit 2
}

exit 0
