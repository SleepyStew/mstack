# Link mstack into Claude Code and Codex on Windows. Safe to run again.
#
# The instructions and skills are links into this clone, so `git pull` updates
# them. Claude Code's settings.json stays a regular file, and the keys in
# claude\settings-overrides.json are merged into it. Run this again after a
# pull adds or removes a skill or changes the overrides. A file or folder
# already in the way is moved to <harness dir>\mstack-backup\<timestamp>\,
# never deleted, and settings.json is copied there before it changes. A link
# in the way is replaced.
#
# Skill folders are linked as junctions, which need no special rights. The
# instruction files are symbolic links, which need Developer Mode (Settings >
# System > For developers) or an elevated shell.

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

# Objects merge key by key. Any other value, lists included, replaces the old one.
function Merge-Object($Base, $Overrides) {
    foreach ($property in $Overrides.PSObject.Properties) {
        $current = $Base.PSObject.Properties[$property.Name]
        if ($current -and $current.Value -is [System.Management.Automation.PSCustomObject] -and $property.Value -is [System.Management.Automation.PSCustomObject]) {
            Merge-Object $current.Value $property.Value
        } elseif ($current) {
            $current.Value = $property.Value
        } else {
            $Base | Add-Member -NotePropertyName $property.Name -NotePropertyValue $property.Value
        }
    }
}

function Merge-Settings($HarnessHome) {
    $target = Join-Path $HarnessHome 'settings.json'
    $overrides = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $repo 'claude\settings-overrides.json') | ConvertFrom-Json
    $item = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
    $isLink = $item -and $item.LinkType
    # A link exists when its target does. Asking the link itself may say yes
    # for a dangling one.
    $linkTarget = if ($isLink) { @($item.Target)[0] } else { $null }
    $existed = if ($isLink) { $linkTarget -and (Test-Path -LiteralPath $linkTarget) } else { [bool]$item }
    # Writing through a dangling link would create a file at its target.
    $dangling = $isLink -and -not $existed
    $base = [pscustomobject]@{}
    if ($existed) {
        try {
            $base = Get-Content -Raw -Encoding UTF8 -LiteralPath $target | ConvertFrom-Json
        } catch {
            throw "$target is not valid JSON. Fix it, then run setup again."
        }
        if ($base -isnot [System.Management.Automation.PSCustomObject]) {
            throw "$target does not hold a JSON object. Fix it, then run setup again."
        }
    }
    $before = $base | ConvertTo-Json -Depth 100 -Compress
    Merge-Object $base $overrides
    if (-not $dangling -and ($base | ConvertTo-Json -Depth 100 -Compress) -ceq $before) {
        Write-Host "  ok      $target"
        return
    }
    if ($dangling) {
        $item.Delete()
    } elseif ($existed) {
        $backup = Join-Path $HarnessHome "mstack-backup\$stamp"
        New-Item -ItemType Directory -Force -Path $backup | Out-Null
        Copy-Item -LiteralPath $target -Destination $backup
    }
    New-Item -ItemType Directory -Force -Path $HarnessHome | Out-Null
    $json = ($base | ConvertTo-Json -Depth 100) + "`n"
    [IO.File]::WriteAllText($target, $json, (New-Object Text.UTF8Encoding $false))
    if ($existed) { Write-Host "  merged  $target" } else { Write-Host "  created $target" }
}

function Test-Installed($Command, $HarnessHome) {
    (Get-Command $Command -ErrorAction SilentlyContinue) -or (Test-Path -LiteralPath $HarnessHome)
}

$claudeHome = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $env:USERPROFILE '.claude' }
$codexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }

if (Test-Installed 'claude' $claudeHome) {
    Write-Host "Claude Code ($claudeHome)"
    Add-Link (Join-Path $repo 'global\AGENTS.md') (Join-Path $claudeHome 'CLAUDE.md') $claudeHome
    Merge-Settings $claudeHome
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
