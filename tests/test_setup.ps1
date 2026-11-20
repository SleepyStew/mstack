# Run setup.ps1 and remove.ps1 against scratch harness folders and check what
# they leave.
# Needs Developer Mode or an elevated shell, as setup.ps1 does.
#
# Run with: powershell -File tests/test_setup.ps1

$ErrorActionPreference = 'Stop'

$repo = Split-Path $PSScriptRoot
$root = Join-Path ([IO.Path]::GetTempPath()) "mstack-test-$([guid]::NewGuid())"
$claude = Join-Path $root 'claude'
$codex = Join-Path $root 'codex'
$skills = Join-Path $claude 'skills'
$elsewhere = Join-Path $root 'elsewhere'
$settings = Join-Path $claude 'settings.json'
$utf8 = New-Object Text.UTF8Encoding $false

function Assert($Condition, $Message) {
    if (-not $Condition) { throw "Failed: $Message" }
}

function Read-Text($Path) {
    [IO.File]::ReadAllText($Path)
}

function Invoke-Setup {
    & (Join-Path $repo 'setup.ps1') @args 6>&1 | ForEach-Object { "$_" }
}

$saved = $env:CLAUDE_CONFIG_DIR, $env:CODEX_HOME
$env:CLAUDE_CONFIG_DIR = $claude
$env:CODEX_HOME = $codex

try {
    New-Item -ItemType Directory -Force -Path $skills, $codex, $elsewhere, (Join-Path $skills 'theirs') | Out-Null
    [IO.File]::WriteAllText((Join-Path $claude 'CLAUDE.md'), 'mine', $utf8)

    Invoke-Setup -All -DryRun | Out-Null
    Assert ((Read-Text (Join-Path $claude 'CLAUDE.md')) -ceq 'mine') 'a dry run leaves CLAUDE.md as it was'
    Assert (-not (Test-Path -LiteralPath (Join-Path $claude 'mstack-backup'))) 'a dry run makes no backup'
    Assert (@(Get-ChildItem -LiteralPath $codex -Force).Count -eq 0) 'a dry run links nothing'

    New-Item -ItemType Junction -Path (Join-Path $skills 'why') -Target $elsewhere | Out-Null
    # A link to a skill that mstack no longer has.
    cmd /c mklink /J (Join-Path $skills 'gone') (Join-Path $repo 'skills\gone') | Out-Null
    Assert ((Get-ChildItem -LiteralPath $skills -Force).Name -contains 'gone') 'the stale link was made'

    $note = "it's <b> & caf" + [char]0xE9
    $when = '2026-11-18T09:30:00+11:00'
    $seed = '{"theme": "light", "note": "' + $note + '", "when": "' + $when + '", "env": {"KEEP": "1"}, "list": [1]}'
    [IO.File]::WriteAllText($settings, $seed, $utf8)

    Invoke-Setup -All | Out-Null

    $instructions = Get-Item -LiteralPath (Join-Path $claude 'CLAUDE.md') -Force
    Assert ($instructions.LinkType -eq 'SymbolicLink') 'CLAUDE.md is a symbolic link'
    Assert ((Read-Text $instructions.FullName) -ceq (Read-Text (Join-Path $repo 'global\AGENTS.md'))) 'CLAUDE.md reads as global\AGENTS.md'
    Assert ((Get-Item -LiteralPath (Join-Path $codex 'AGENTS.md') -Force).LinkType -eq 'SymbolicLink') 'the Codex AGENTS.md is a symbolic link'

    $backup = @(Get-ChildItem -LiteralPath (Join-Path $claude 'mstack-backup'))
    Assert ($backup.Count -eq 1) 'there is one backup folder'
    Assert ((Read-Text (Join-Path $backup[0].FullName 'CLAUDE.md')) -ceq 'mine') 'the old CLAUDE.md is in the backup'
    Assert ((Read-Text (Join-Path $backup[0].FullName 'settings.json')) -ceq $seed) 'the old settings.json is in the backup'

    foreach ($skill in Get-ChildItem -LiteralPath (Join-Path $repo 'skills') -Directory) {
        foreach ($harness in $claude, $codex) {
            $link = Get-Item -LiteralPath (Join-Path $harness "skills\$($skill.Name)") -Force
            Assert ($link.LinkType -eq 'Junction') "$($link.FullName) is a junction"
            Assert (Test-Path -LiteralPath (Join-Path $link.FullName 'SKILL.md')) "$($link.FullName) leads to the skill"
        }
    }
    Assert (Test-Path -LiteralPath $elsewhere) 'the folder a replaced link pointed at is still there'
    $names = (Get-ChildItem -LiteralPath $skills -Force).Name
    Assert ($names -notcontains 'gone') 'the link to a skill mstack no longer has is removed'
    Assert ($names -contains 'theirs') 'a skill that is not from mstack is left alone'

    $text = Read-Text $settings
    $merged = $text | ConvertFrom-Json
    $overrides = Read-Text (Join-Path $repo 'claude\settings-overrides.json') | ConvertFrom-Json
    foreach ($property in $overrides.PSObject.Properties) {
        Assert ($merged.PSObject.Properties[$property.Name]) "the override $($property.Name) is applied"
    }
    Assert ($merged.theme -ceq 'light') 'a setting the overrides do not name is kept'
    Assert ($merged.env.KEEP -ceq '1') 'an object merges key by key'
    Assert (-not $merged.env.PSObject.Properties['CLAUDE_CODE_SHELL']) 'the shell override is left to Claude Code'
    Assert ($merged.note -ceq $note) 'quotes, angle brackets and accents survive'
    # PowerShell 6 to 7.4 cannot keep one, which the readme says.
    if ($PSVersionTable.PSVersion.Major -lt 6 -or (Get-Command ConvertFrom-Json).Parameters.ContainsKey('DateKind')) {
        Assert ($text.Contains($when)) 'a string that looks like a date is written back unchanged'
    }
    Assert ($text -match '"list":\s*\[\s*1\s*\]') 'a one-item list stays a list'

    $changed = @(Invoke-Setup -All | Where-Object { $_ -match '^  ' -and $_ -notmatch '^  ok ' })
    Assert ($changed.Count -eq 0) "a second run changes nothing, but it printed: $changed"
    Assert ((Read-Text $settings) -ceq $text) 'a second run leaves settings.json as it was'

    & (Join-Path $repo 'remove.ps1') 6>&1 | Out-Null
    $restored = Get-Item -LiteralPath (Join-Path $claude 'CLAUDE.md') -Force
    Assert (-not $restored.LinkType -and (Read-Text $restored.FullName) -ceq 'mine') 'remove puts back the CLAUDE.md that setup moved aside'
    Assert (-not (Test-Path -LiteralPath (Join-Path $codex 'AGENTS.md'))) 'remove takes out the Codex AGENTS.md link'
    Assert (@(Get-ChildItem -LiteralPath (Join-Path $codex 'skills') -Force).Count -eq 0) 'remove takes out the Codex skill links'
    $names = @((Get-ChildItem -LiteralPath $skills -Force).Name)
    Assert ($names.Count -eq 1 -and $names[0] -ceq 'theirs') "remove leaves only the skill that is not from mstack, but found: $names"
    Assert (Test-Path -LiteralPath (Join-Path $repo 'skills\why\SKILL.md')) 'remove leaves the skills in the clone'
    Assert ((Read-Text $settings) -ceq $text) 'remove leaves settings.json as it was'

    [IO.File]::WriteAllText($settings, $seed, $utf8)
    Invoke-Setup | Out-Null
    Assert ((Read-Text $settings) -ceq $seed) 'setup without -ApplySettings leaves settings.json as it was'
    Assert ((Read-Text (Join-Path $claude 'CLAUDE.md')) -ceq 'mine') 'setup without -ApplyInstructions leaves CLAUDE.md as it was'
    Assert (-not (Test-Path -LiteralPath (Join-Path $codex 'AGENTS.md'))) 'setup without -ApplyInstructions links no Codex AGENTS.md'

    Write-Host "setup.ps1 tests passed on PowerShell $($PSVersionTable.PSVersion)"
} finally {
    $env:CLAUDE_CONFIG_DIR, $env:CODEX_HOME = $saved
    # Links go first. Removing a folder tree in Windows PowerShell can follow
    # a junction and empty the folder it points at.
    foreach ($folder in $claude, $codex, $skills, (Join-Path $codex 'skills')) {
        Get-ChildItem -LiteralPath $folder -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LinkType } |
            ForEach-Object { $_.Delete() }
    }
    Remove-Item -LiteralPath $root -Recurse -Force
}
