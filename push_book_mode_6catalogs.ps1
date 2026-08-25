# Unzips the 6 book-mode data packages into their catalog folders, unzips the
# bootstrap widgets, then commits and pushes the diagrams repo in one shot.
# Run this from anywhere -- it cd's to the right places itself.

$root = "C:\Users\Admin\Documents\Website\Interactive Parts Catalogs"
$diagramsRepo = Join-Path $root "ingersoll-catalog-diagrams"
$widgetHtml = Join-Path $root "ingersoll-widget-html"

$catalogs = @("8-1242", "8-1301", "8-1641", "8-1642", "8-1870", "8-2052")

foreach ($cat in $catalogs) {
    $catFolder = Join-Path $diagramsRepo $cat
    $zip = Join-Path $catFolder "book_mode_data_$cat.zip"
    if (Test-Path $zip) {
        Write-Host "Extracting $zip ..."
        Expand-Archive -Path $zip -DestinationPath $catFolder -Force
        Remove-Item $zip
    } else {
        Write-Warning "$zip not found -- skipping $cat"
    }
}

$bootstrapZip = Join-Path $widgetHtml "bootstrap_widgets_book_6catalogs.zip"
if (Test-Path $bootstrapZip) {
    Write-Host "Extracting $bootstrapZip ..."
    Expand-Archive -Path $bootstrapZip -DestinationPath $widgetHtml -Force
    Remove-Item $bootstrapZip
    # the zip contains a "bootstraps\" subfolder -- flatten it up one level
    $inner = Join-Path $widgetHtml "bootstraps"
    if (Test-Path $inner) {
        Get-ChildItem $inner -Filter *.html | Move-Item -Destination $widgetHtml -Force
        Remove-Item $inner -Recurse -Force
    }
} else {
    Write-Warning "$bootstrapZip not found -- skipping bootstrap widgets"
}

Write-Host "Committing and pushing ingersoll-catalog-diagrams ..."
Set-Location $diagramsRepo
git add -A
git commit -m "Add book-mode data (book-index.json + sections/) for 8-1242, 8-1301, 8-1641, 8-1642, 8-1870, 8-2052"
git push

Write-Host "Done. Verify with: git log -1 --stat"
