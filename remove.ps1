# Take mstack's links out of Claude Code and Codex on Windows. Safe to run again.
#
# Only links that point into this clone are removed. Where setup moved a file
# or folder aside to make room for a link, the newest copy in mstack-backup is
# moved back. settings.json keeps any overrides that setup merged, since it
# may have changed since and putting an old copy back would lose that.

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
        if (-not ($target -and ($ours | Where-Object { $target.StartsWith($_, [StringComparison]::OrdinalIgnoreCase) }))) { continue }
        $path = $entry.FullName
        $entry.Delete()
        Write-Host "  removed  $path"
        $relative = $path.Substring($HarnessHome.Length).TrimStart('\')
        # Backup folders are named by timestamp, so the last match is the newest.
        $newest = Get-ChildItem -LiteralPath (Join-Path $HarnessHome 'mstack-backup') -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name |
            ForEach-Object { Join-Path $_.FullName $relative } |
            Where-Object { Test-Path -LiteralPath $_ } |
            Select-Object -Last 1
        if ($newest) {
            Move-Item -LiteralPath $newest -Destination $path
            Write-Host "  restored $path (from $newest)"
        }
    }
}

Remove-Links $(if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }) 'CLAUDE.md'
Remove-Links $(if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }) 'AGENTS.md'

Write-Host 'Done. settings.json was not touched, and its earlier copies are in mstack-backup. Sessions already running keep what they loaded.'
