# HIDE context menu clutter (safe, reversible)
# Run as Administrator

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Disable-Key($path, $name) {
    if ($name.StartsWith("__DISABLED__")) { return }
    Rename-Item -Path $path -NewName ("__DISABLED__" + $name)
    Write-Host "Disabled: $name"
}

function Restart-Explorer {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer.exe
}

# Extensions to scan
$Extensions = @(
    ".pdf",
    ".jpg",".jpeg",".png",".gif",".bmp",".webp",".tiff",
    ".txt",".md",
    ".docx",".xlsx",".pptx",
    ".zip",".rar",".7z"
)

function Get-Locations($ext) {
    @(
        "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\$ext\shellex\ContextMenuHandlers",
        "Registry::HKEY_CLASSES_ROOT\$ext\shellex\ContextMenuHandlers",
        "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\$ext\shell",
        "Registry::HKEY_CLASSES_ROOT\$ext\shell"
    )
}

$GlobalShellex = @(
    "Registry::HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers",
    "Registry::HKEY_CLASSES_ROOT\AllFileSystemObjects\shellex\ContextMenuHandlers"
)

# 1) Zakázat THIRD-PARTY shellex (cloud + MS zůstane)
$ThirdPartyRegex = 'WinRAR|7-Zip|XChange|Adobe|Copilot|EPP|Defender|GIMP|Photoshop|Notepad\+\+|VSCode'

foreach ($ext in $Extensions) {
    foreach ($loc in Get-Locations $ext) {
        if (Test-Path $loc) {
            Get-ChildItem $loc | Where-Object {
                $_.PSChildName -match $ThirdPartyRegex
            } | ForEach-Object {
                Disable-Key $_.PSPath $_.PSChildName
            }
        }
    }
}

foreach ($loc in $GlobalShellex) {
    if (Test-Path $loc) {
        Get-ChildItem $loc | Where-Object {
            $_.PSChildName -match $ThirdPartyRegex
        } | ForEach-Object {
            Disable-Key $_.PSPath $_.PSChildName
        }
    }
}

# 2) Pročistit shell, ale NECHAT: openwith / edit / share
foreach ($ext in $Extensions) {
    foreach ($loc in Get-Locations $ext) {
        if ($loc -match '\\shell$' -and (Test-Path $loc)) {
            Get-ChildItem $loc | Where-Object {
                $_.PSChildName -notmatch '^(openwith|edit|share)$'
            } | ForEach-Object {
                Disable-Key $_.PSPath $_.PSChildName
            }
        }
    }
}

Restart-Explorer
Write-Host "DONE: context menu minimized"
