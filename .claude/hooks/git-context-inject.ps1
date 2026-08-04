# UserPromptSubmit hook.
# Prints branch + short status to stdout; Claude Code appends this to context.
# Informational only - always exits 0.

$ErrorActionPreference = 'SilentlyContinue'

$inGitRepo = git rev-parse --is-inside-work-tree 2>$null
if ($inGitRepo -ne 'true') {
    exit 0
}

$branch = git rev-parse --abbrev-ref HEAD 2>$null
$status = git status -sb 2>$null

if ($branch) {
    Write-Output "[git] branch: $branch"
}
if ($status) {
    Write-Output "[git] status:"
    Write-Output $status
}

exit 0
