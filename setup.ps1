# =============================================================
# setup.ps1 - First time project initialization (Windows)
# Usage: powershell -File setup.ps1
# =============================================================

$ErrorActionPreference = 'Stop'

$ClaudeMd = "CLAUDE.md"
$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm'

function Log($msg)  { Write-Host "[SETUP] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[WARN] $msg" -ForegroundColor Yellow }

Write-Host ""
Write-Host "========================================"
Write-Host "  Project Setup"
Write-Host "========================================"
Write-Host ""

$ProjectName = ""
while ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Read-Host "Project name (e.g. my-app)"
    if ([string]::IsNullOrWhiteSpace($ProjectName)) { Warn "Cannot be empty." }
}

if (-not (Test-Path $ClaudeMd)) {
    Warn "$ClaudeMd not found in current directory. Run this from the project root."
    exit 1
}

(Get-Content $ClaudeMd -Raw) `
    -replace '\{PROJECT_NAME\}', $ProjectName `
    -replace '\{SETUP_DATE\}', $Timestamp |
    Set-Content -Path $ClaudeMd -Encoding utf8 -NoNewline

Log "Project name set: $ProjectName"

New-Item -ItemType Directory -Force -Path 'code' | Out-Null
Log "code/ ready. Put your source in there, in whatever stack you're using."

Write-Host ""
Log "Setup complete."
Log "Next steps:"
Write-Host "  1. Write docs/SRS.md and docs/PRD.md."
Write-Host "  2. Run: powershell -File sync.ps1 (syncs docs/SRS.md Stack section into CLAUDE.md)"
Write-Host "  3. Start working task by task, Plan Mode first for anything non-trivial."
Write-Host "  4. See SCRATCHPAD.md for open work, DECISION-LOG.md for the history."
Write-Host ""
