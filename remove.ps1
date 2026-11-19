# Take mstack's links out of Claude Code and Codex on Windows. Safe to run again.
#
# Only links that point into this clone are removed. settings.json keeps any
# overrides that setup merged, since it may have changed since and putting an
# old copy back would lose that. The mstack-backup folders stay, so their
# contents can be put back by hand.

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$ours = (Join-Path $repo 'global\AGENTS.md'), ((Join-Path $repo 'skills') + '\')

function Remove-Links($HarnessHome, $Instructions) {
    if (-not (Test-Path -LiteralPath $HarnessHome)) { return }
    Write-Host $HarnessHome
    $entries = @(Get-Item -LiteralPath (Join-Path $HarnessHome $Instructions) -Force -ErrorAction SilentlyContinue)
    $entries += @(Get-ChildItem -LiteralPath (Join-Path $HarnessHome 'skills') -Force -ErrorAction SilentlyContinue)
    foreach ($entry in $entries) {
        if (-not $entry.LinkType) { continue }
        $target = @($entry.Target)[0]
        if ($target -and ($ours | Where-Object { $target.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) })) {
            $entry.Delete()
            Write-Host "  removed $($entry.FullName)"
        }
    }
    $backup = Join-Path $HarnessHome 'mstack-backup'
    if (Test-Path -LiteralPath $backup) {
        Write-Host "  What setup moved aside is still in $backup"
    }
}

Remove-Links $(if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }) 'CLAUDE.md'
Remove-Links $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }) 'AGENTS.md'

Write-Host 'Done. settings.json was not touched. Sessions already running keep what they loaded.'
