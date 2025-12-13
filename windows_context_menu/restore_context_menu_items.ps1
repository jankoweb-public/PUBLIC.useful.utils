# RESTORE context menu (undo all changes)
# Run as Administrator

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Enable-Key($path, $name) {
    if (-not $name.StartsWith("__DISABLED__")) { return }
    $new = $name -replace '^__DISABLED__',''
    Rename-Item -Path $path -NewName $new
    Write-Host "Enabled: $new"
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
Write-Host "DONE: context menu restored"
