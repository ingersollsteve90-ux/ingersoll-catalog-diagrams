# One-time fix: the original book_mode_data_8-3042.zip had a redundant
# top-level "8-3042\" folder baked in, so extracting it into the
# already-named 8-3042\ destination landed everything one level too deep
# (8-3042\8-3042\book-index.json / 8-3042\8-3042\sections\...) instead of
# directly inside 8-3042\. This moves the misplaced files up one level,
# removes the now-empty nested folder, verifies the layout is correct,
# then commits and pushes -- same as push_book_mode_8-3042.ps1 was always
# going to do, just with the self-heal step added first.

$root = "C:\Users\Admin\Documents\Website\Interactive Parts Catalogs"
$diagramsRepo = Join-Path $root "ingersoll-catalog-diagrams"
$cat = "8-3042"
$catFolder = Join-Path $diagramsRepo $cat
$nestedFolder = Join-Path $catFolder $cat   # ...\8-3042\8-3042

if (Test-Path $nestedFolder) {
    Write-Host "Found the misplaced nested folder at $nestedFolder -- moving its contents up into $catFolder ..."
    Get-ChildItem $nestedFolder | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $catFolder -Force
    }
    Remove-Item $nestedFolder -Recurse -Force
    Write-Host "Moved and removed the empty nested folder."
} else {
    Write-Host "No nested folder found at $nestedFolder -- nothing to move (already fixed, or extraction landed correctly)."
}

# Sanity check before committing: book-index.json + sections\ should now
# sit directly inside the catalog folder, not nested deeper or duplicated.
$indexPath = Join-Path $catFolder "book-index.json"
$sectionsPath = Join-Path $catFolder "sections"
if (-not (Test-Path $indexPath) -or -not (Test-Path $sectionsPath)) {
    Write-Host "ERROR: book-index.json / sections\ still not found directly inside $catFolder -- stop and check the folder layout by hand before committing." -ForegroundColor Red
    exit 1
}
$sectionCount = (Get-ChildItem $sectionsPath -Filter *.json).Count
Write-Host "Layout OK: book-index.json present, sections\ contains $sectionCount files (expect 51)."

Set-Location $diagramsRepo
git add -A
git commit -m "Add book-mode data (book-index.json + sections/) for 8-3042"
git push

Write-Host ""
Write-Host "Done. If the commit/push above succeeded, book-mode data for 8-3042 is now live." -ForegroundColor Green
Write-Host "Data URL to spot-check once jsDelivr resolves: https://cdn.jsdelivr.net/gh/ingersollsteve90-ux/ingersoll-catalog-diagrams@main/8-3042/book-index.json"
