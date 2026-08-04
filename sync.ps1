# =============================================================
# sync.ps1 - Sync stack info from SRS.md into CLAUDE.md (Windows)
# Usage: powershell -File sync.ps1
# Run after updating docs/SRS.md
# =============================================================

$ErrorActionPreference = 'Stop'

$SrsFile   = "docs/SRS.md"
$ClaudeMd  = "CLAUDE.md"
$LogFile   = "logs/sync.log"
$Timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'

function Write-Log {
    param([string]$Level, [string]$Msg, [string]$Color)
    $line = "[$Timestamp] $Level$Msg"
    Write-Host "[$Level] $Msg" -ForegroundColor $Color
    Add-Content -Path $LogFile -Value $line
}
function Log($msg)   { Write-Log -Level "SYNC "  -Msg $msg -Color Green }
function Warn($msg)  { Write-Log -Level "WARN: " -Msg $msg -Color Yellow }
function ErrorMsg($msg) { Write-Log -Level "ERROR: " -Msg $msg -Color Red }

New-Item -ItemType Directory -Force -Path 'logs' | Out-Null

foreach ($f in @($SrsFile, $ClaudeMd)) {
    if (-not (Test-Path $f)) {
        ErrorMsg "Missing: $f"
        exit 1
    }
}

# Parse ## Stack section from SRS.md (stops at next ## heading)
$lines = Get-Content $SrsFile
$stackLines = @()
$inStack = $false
foreach ($line in $lines) {
    if ($line -match '^## Stack') {
        $inStack = $true
        continue
    }
    if ($inStack -and $line -match '^## ') {
        break
    }
    if ($inStack -and $line -match '^\s*-\s+(.+)$') {
        $stackLines += $Matches[1]
    }
}

if ($stackLines.Count -eq 0) {
    Warn "No ## Stack section found in $SrsFile. CLAUDE.md stack not updated."
    exit 0
}

Log "Parsed stack from ${SrsFile}:"
foreach ($l in $stackLines) { Write-Host "  - $l" }

$stackBlock = "## Stack (auto-synced from SRS.md on $Timestamp)`n"
foreach ($l in $stackLines) { $stackBlock += "- $l`n" }

$content = Get-Content $ClaudeMd -Raw
$pattern = '(?s)<!-- STACK_START -->.*?<!-- STACK_END -->'
$replacement = "<!-- STACK_START -->`n$stackBlock<!-- STACK_END -->"
$newContent = [regex]::Replace($content, $pattern, { param($m) $replacement })
Set-Content -Path $ClaudeMd -Value $newContent -Encoding utf8 -NoNewline

Log "CLAUDE.md updated."
Log "Sync log: $LogFile"
