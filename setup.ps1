# Link mstack into Claude Code and Codex on Windows. Safe to run again.
#
# Everything is a link into this clone, so `git pull` updates it. Run this
# again only after a pull adds or removes a skill. Anything already in the way
# is moved to <harness dir>\mstack-backup\<timestamp>\, never deleted.
#
# Skill folders are linked as junctions, which need no special rights. The two
# files are symbolic links, which need Developer Mode (Settings > System > For
# developers) or an elevated shell.

$ErrorActionPreference = 'Stop'

$repo = $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Test-LinkTo($Item, $Source) {
    if (-not $Item.LinkType) { return $false }
    foreach ($target in @($Item.Target)) {
        if ([IO.Path]::GetFullPath($target).TrimEnd('\') -ieq [IO.Path]::GetFullPath($Source).TrimEnd('\')) {
            return $true
        }
    }
    return $false
}

function Add-Link($Source, $Target, $HarnessHome, [switch]$Directory) {
    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($item -and (Test-LinkTo $item $Source)) {
        Write-Host "  ok      $Target"
        return
    }
    if ($item -and $item.LinkType) {
        # A link pointing somewhere else. Deleting a link leaves its target alone.
        $item.Delete()
    } elseif ($item) {
        $relative = $Target.Substring($HarnessHome.Length).TrimStart('\')
        $backup = Join-Path $HarnessHome (Join-Path "mstack-backup\$stamp" $relative)
        New-Item -ItemType Directory -Force -Path (Split-Path $backup) | Out-Null
        Move-Item -LiteralPath $Target -Destination $backup
        Write-Host "  backup  $Target -> $backup"
    }
    New-Item -ItemType Directory -Force -Path (Split-Path $Target) | Out-Null
    if ($Directory) {
        New-Item -ItemType Junction -Path $Target -Target $Source | Out-Null
    } else {
        try {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
        } catch {
            throw "Could not link $Target. Turn on Developer Mode (Settings > System > For developers) or run this in an elevated shell, then run it again."
        }
    }
    Write-Host "  linked  $Target"
}

# Link every skill, then drop links to skills this clone no longer has.
function Add-SkillLinks($HarnessHome) {
    $skills = Join-Path $HarnessHome 'skills'
    foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $repo 'skills') -Directory) {
        Add-Link $skill.FullName (Join-Path $skills $skill.Name) $HarnessHome -Directory
    }
    $ours = (Join-Path $repo 'skills') + '\'
    foreach ($entry in Get-ChildItem -LiteralPath $skills -Force) {
        if (-not $entry.LinkType) { continue }
        $target = @($entry.Target)[0]
        if ($target -and $target.StartsWith($ours, [StringComparison]::OrdinalIgnoreCase) -and -not (Test-Path -LiteralPath $target)) {
            $entry.Delete()
            Write-Host "  removed $($entry.FullName) (skill no longer in mstack)"
        }
    }
}

function Test-Installed($Command, $HarnessHome) {
    (Get-Command $Command -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $HarnessHome)
}

$claudeHome = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }

if (Test-Installed 'claude' $claudeHome) {
    Write-Host "Claude Code ($claudeHome)"
    Add-Link (Join-Path $repo 'global\AGENTS.md') (Join-Path $claudeHome 'CLAUDE.md') $claudeHome
    Add-Link (Join-Path $repo 'claude\settings.json') (Join-Path $claudeHome 'settings.json') $claudeHome
    Add-SkillLinks $claudeHome
} else {
    Write-Host 'Claude Code: not installed, skipped. Run this again once it is.'
}

if (Test-Installed 'codex' $codexHome) {
    Write-Host "Codex ($codexHome)"
    Add-Link (Join-Path $repo 'global\AGENTS.md') (Join-Path $codexHome 'AGENTS.md') $codexHome
    Add-SkillLinks $codexHome
} else {
    Write-Host 'Codex: not installed, skipped. Run this again once it is.'
}

Write-Host 'Done. New sessions pick this up. Sessions already running keep what they loaded.'
