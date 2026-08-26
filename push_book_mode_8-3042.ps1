# Unzips the 8-3042 book-mode data package into its catalog folder, then
# commits and pushes the diagrams repo in one shot.
#
# NOTE: Expand-Archive on this machine has been observed to also create a
# redundant nested copy under a subfolder named after the zip's own basename
# (e.g. 8-3042\book_mode_data_8-3042\...) in addition to the correct flat
# files. This script removes that duplicate immediately after extracting,
# so no separate cleanup pass is needed. (Windows' built-in "Extract All"
# has a different failure mode -- drops contents one level too deep instead
# -- so stick to this script's Expand-Archive rather than extracting by hand.)

$root = "C:\Users\Admin\Documents\Website\Interactive Parts Catalogs"
$diagramsRepo = Join-Path $root "ingersoll-catalog-diagrams"
$cat = "8-3042"

$catFolder = Join-Path $diagramsRepo $cat
$zip = Join-Path $catFolder "book_mode_data_$cat.zip"

if (-not (Test-Path $zip)) {
    Write-Host "ERROR: expected zip not found at $zip -- place book_mode_data_8-3042.zip in that folder first." -ForegroundColor Red
    exit 1
}

Expand-Archive -Path $zip -DestinationPath $catFolder -Force
Remove-Item $zip

# Clean up the Expand-Archive duplicate-folder artifact, if present.
$dupFolder = Join-Path $catFolder "book_mode_data_$cat"
if (Test-Path $dupFolder) {
    Remove-Item $dupFolder -Recurse -Force
}

# Sanity check before committing: book-index.json + sections\ should now
# sit directly inside the catalog folder, not nested deeper or duplicated.
$indexPath = Join-Path $catFolder "book-index.json"
$sectionsPath = Join-Path $catFolder "sections"
if (-not (Test-Path $indexPath) -or -not (Test-Path $sectionsPath)) {
    Write-Host "ERROR: after extraction, book-index.json / sections\ were not found directly inside $catFolder -- stop and check the folder layout before committing." -ForegroundColor Red
    exit 1
}
$sectionCount = (Get-ChildItem $sectionsPath -Filter *.json).Count
Write-Host "Extracted OK: book-index.json present, sections\ contains $sectionCount files (expect 51)."

Set-Location $diagramsRepo
git add -A
git commit -m "Add book-mode data (book-index.json + sections/) for 8-3042"
git push

Write-Host ""
Write-Host "Done. If the commit/push above succeeded, book-mode data for 8-3042 is now live." -ForegroundColor Green
Write-Host "Data URL to spot-check once jsDelivr resolves: https://cdn.jsdelivr.net/gh/ingersollsteve90-ux/ingersoll-catalog-diagrams@main/8-3042/book-index.json"
