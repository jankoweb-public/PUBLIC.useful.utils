# RESTORE context menu (undo all changes)
# Run as Administrator

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$EnabledItems = @()

function Enable-Key($path, $name) {
    if (-not $name.StartsWith("__DISABLED__")) { return }
    try {
        $new = $name -replace '^__DISABLED__',''
        Rename-Item -Path $path -NewName $new
        Write-Host "  + Enabled: $new" -ForegroundColor Gray
        $script:EnabledItems += $new
    } catch {
        Write-Host "Warning: Error enabling '$name': $_" -ForegroundColor Yellow
    }
}

function Restart-Explorer {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Process explorer.exe
}

$Roots = @(
    "Registry::HKEY_CLASSES_ROOT\*",
    "Registry::HKEY_CLASSES_ROOT\AllFileSystemObjects",
    "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations",
    "Registry::HKEY_CLASSES_ROOT\.pdf",
    "Registry::HKEY_CLASSES_ROOT\.jpg",
    "Registry::HKEY_CLASSES_ROOT\.jpeg",
    "Registry::HKEY_CLASSES_ROOT\.png",
    "Registry::HKEY_CLASSES_ROOT\.txt",
    "Registry::HKEY_CLASSES_ROOT\.docx",
    "Registry::HKEY_CLASSES_ROOT\.xlsx",
    "Registry::HKEY_CLASSES_ROOT\.pptx"
)

Write-Host "Restoring context menu..." -ForegroundColor Cyan
Write-Host ""

foreach ($root in $Roots) {
    if (Test-Path $root) {
        Get-ChildItem -Recurse -ErrorAction SilentlyContinue $root |
            Where-Object { $_.PSChildName -like '__DISABLED__*' } |
            ForEach-Object {
                Enable-Key $_.PSPath $_.PSChildName
            }
    }
}

Restart-Explorer

Write-Host "========================================"
Write-Host "DONE: Context menu restored" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""

if ($EnabledItems.Count -gt 0) {
    Write-Host "Items restored:" -ForegroundColor Green
    $EnabledItems | Sort-Object -Unique | ForEach-Object {
        Write-Host "  * $_" -ForegroundColor Gray
    }
} else {
    Write-Host "No items were changed." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Total: $($EnabledItems.Count) items enabled" -ForegroundColor Green
Write-Host ""
