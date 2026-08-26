# Unzips the 4 book-mode data packages into their catalog folders, unzips the
# bootstrap widgets, then commits and pushes the diagrams repo in one shot.
#
# NOTE: Expand-Archive on this machine has been observed to also create a
# redundant nested copy under a subfolder named after the zip's own basename
# (e.g. 8-3031\book_mode_data_8-3031\...) in addition to the correct flat
# files. This script removes that duplicate immediately after each extract,
# so no separate cleanup pass is needed this time.

$root = "C:\Users\Admin\Documents\Website\Interactive Parts Catalogs"
$diagramsRepo = Join-Path $root "ingersoll-catalog-diagrams"
$widgetHtml = Join-Path $root "ingersoll-widget-html"
$catalogs = @("8-3031", "8-3112", "8-3200", "A1159")

foreach ($cat in $catalogs) {
    $catFolder = Join-Path $diagramsRepo $cat
    $zip = Join-Path $catFolder "book_mode_data_$cat.zip"
    if (Test-Path $zip) {
        Expand-Archive -Path $zip -DestinationPath $catFolder -Force
        Remove-Item $zip

        # Clean up the Expand-Archive duplicate-folder artifact, if present.
        $dupFolder = Join-Path $catFolder "book_mode_data_$cat"
        if (Test-Path $dupFolder) {
            Remove-Item $dupFolder -Recurse -Force
        }
    }
}

$bootstrapZip = Join-Path $widgetHtml "bootstrap_widgets_book_4catalogs.zip"
if (Test-Path $bootstrapZip) {
    Expand-Archive -Path $bootstrapZip -DestinationPath $widgetHtml -Force
    Remove-Item $bootstrapZip

    # Same duplicate-folder cleanup, checked at both possible nesting depths.
    $dup1 = Join-Path $widgetHtml "bootstrap_widgets_book_4catalogs"
    if (Test-Path $dup1) {
        Remove-Item $dup1 -Recurse -Force
    }
}

Set-Location $diagramsRepo
git add -A
git commit -m "Add book-mode data (book-index.json + sections/) for 8-3031, 8-3112, 8-3200, A1159"
git push
