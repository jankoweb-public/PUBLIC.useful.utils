# HIDE context menu clutter (safe, reversible)
# Run as Administrator

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$DisabledItems = @()

function Disable-Key($path, $name) {
    if ($name.StartsWith("__DISABLED__")) { return }
    try {
        Rename-Item -Path $path -NewName ("__DISABLED__" + $name)
        Write-Host "  - Disabled: $name" -ForegroundColor Gray
        $script:DisabledItems += $name
    } catch {
        Write-Host "Warning: Error disabling '$name': $_" -ForegroundColor Yellow
    }
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

# 1) Disable THIRD-PARTY shellex (cloud + Microsoft items stay)
$ThirdPartyRegex = 'WinRAR|7-Zip|XChange|Adobe|Copilot|EPP|Defender|GIMP|Photoshop|Notepad\+\+|VSCode'

Write-Host "Processing third-party shell extensions..." -ForegroundColor Cyan

$count = 0
foreach ($ext in $Extensions) {
    $count++
    Write-Host "[$count/$($Extensions.Count)] Scanning: $ext" -ForegroundColor DarkGray
    foreach ($loc in Get-Locations $ext) {
        if (Test-Path $loc) {
            try {
                $items = @(Get-ChildItem $loc -ErrorAction Stop)
                foreach ($item in $items) {
                    if ($item.PSChildName -match $ThirdPartyRegex) {
                        Disable-Key $item.PSPath $item.PSChildName
                    }
                }
            } catch {
                # Skip if access denied
            }
        }
    }
}
Write-Host "Processing global shell extensions..." -ForegroundColor DarkGray
foreach ($loc in $GlobalShellex) {
    if (Test-Path $loc) {
        try {
            Write-Host "  Checking: $loc" -ForegroundColor DarkGray
            $items = @(Get-ChildItem $loc -ErrorAction Stop | Where-Object { $_.PSChildName -match $ThirdPartyRegex })
            Write-Host "  Found $($items.Count) items to process" -ForegroundColor DarkGray
            foreach ($item in $items) {
                Disable-Key $item.PSPath $item.PSChildName
            }
        } catch {
            Write-Host "  Skipped (access denied or error)" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "Cleaning up shell menu..." -ForegroundColor Cyan

$count = 0
foreach ($ext in $Extensions) {
    $count++
    Write-Host "[$count/$($Extensions.Count)] Scanning: $ext" -ForegroundColor DarkGray
    foreach ($loc in Get-Locations $ext) {
        if ($loc -match '\\shell$' -and (Test-Path $loc)) {
            try {
                $items = @(Get-ChildItem $loc -ErrorAction Stop)
                foreach ($item in $items) {
                    if ($item.PSChildName -notmatch '^(openwith|edit|share)$') {
                        Disable-Key $item.PSPath $item.PSChildName
                    }
                }
            } catch {
                # Skip if access denied
            }
        }
    }
}

Restart-Explorer

Write-Host "========================================"
Write-Host "DONE: Context menu cleaned" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""

if ($DisabledItems.Count -gt 0) {
    Write-Host "Items removed:" -ForegroundColor Green
    $DisabledItems | Sort-Object -Unique | ForEach-Object {
        Write-Host "  * $_" -ForegroundColor Gray
    }
} else {
    Write-Host "No items were changed." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Total: $($DisabledItems.Count) items disabled" -ForegroundColor Green
Write-Host ""
