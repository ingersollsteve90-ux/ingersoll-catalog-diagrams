# upload_catalog.ps1
# Usage: .\upload_catalog.ps1 -CatalogNumber "8-3200" -SourceFolder "C:\path\to\new\diagrams"
#
# Copies a folder of diagram JPEGs into the right subfolder of this repo,
# then commits and pushes them all in one shot.

param(
    [Parameter(Mandatory=$true)]
    [string]$CatalogNumber,

    [Parameter(Mandatory=$true)]
    [string]$SourceFolder
)

$destFolder = Join-Path $PSScriptRoot $CatalogNumber

if (-not (Test-Path $destFolder)) {
    New-Item -ItemType Directory -Path $destFolder | Out-Null
    Write-Host "Created folder: $destFolder"
}

Copy-Item -Path (Join-Path $SourceFolder "*.jpg") -Destination $destFolder -Force
$count = (Get-ChildItem $destFolder -Filter "*.jpg").Count
Write-Host "Copied images into $destFolder (now contains $count files)"

git add $CatalogNumber
git commit -m "Add catalog $CatalogNumber diagrams"
git push

Write-Host ""
Write-Host "Done. jsDelivr URL pattern for this catalog:"
Write-Host "https://cdn.jsdelivr.net/gh/ingersollsteve90-ux/ingersoll-catalog-diagrams@main/$CatalogNumber/FILENAME.jpg"
