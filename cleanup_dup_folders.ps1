# Removes the redundant "book_mode_data_<CATALOG>\" subfolders that
# Expand-Archive left behind duplicating the correct top-level
# book-index.json / sections\ files already sitting next to them.

$diagramsRepo = "C:\Users\Admin\Documents\Website\Interactive Parts Catalogs\ingersoll-catalog-diagrams"
$catalogs = @("8-1242", "8-1301", "8-1641", "8-1642", "8-1870", "8-2052")

Set-Location $diagramsRepo
foreach ($cat in $catalogs) {
    $dupFolder = Join-Path $diagramsRepo "$cat\book_mode_data_$cat"
    if (Test-Path $dupFolder) {
        Write-Host "Removing $dupFolder ..."
        Remove-Item $dupFolder -Recurse -Force
    }
}

git add -A
git commit -m "Remove duplicate book_mode_data_<CATALOG> subfolders (Expand-Archive artifact)"
git push

Write-Host "Done. Verify with: git log -1 --stat"
