# PreToolUse hook for Write|Edit.
# Reads the tool_input JSON from stdin, blocks writes to secret/credential files.
# Exit 2 = block (Claude Code shows stderr as the reason). Exit 0 = allow.

$ErrorActionPreference = 'Stop'

try {
    $stdin = [Console]::In.ReadToEnd()
    $payload = $stdin | ConvertFrom-Json
    $filePath = $payload.tool_input.file_path
} catch {
    # If we can't parse input, fail open rather than blocking legitimate work.
    exit 0
}

if (-not $filePath) {
    exit 0
}

$denyPatterns = @(
    '(^|[\\/])\.env($|\.[^\\/]*$)',
    '\.pem$',
    '\.key$',
    '\.pfx$',
    '\.p12$',
    'id_rsa(\.[^\\/]*)?$',
    'id_ed25519(\.[^\\/]*)?$',
    '(^|[\\/])credentials([^\\/]*)$',
    '(^|[\\/])secrets?([^\\/]*)$',
    '\.pgpass$',
    '(^|[\\/])\.aws([\\/]|$)'
)

foreach ($pattern in $denyPatterns) {
    if ($filePath -match $pattern) {
        [Console]::Error.WriteLine("write-guard: blocked write to '$filePath' - matches secret-file pattern '$pattern'. Edit this file yourself outside Claude Code if intentional.")
        exit 2
    }
}

exit 0
