# Fix texture issues for Legacy of Divinity
Write-Host "Fixing texture issues..." -ForegroundColor Cyan

$projectPath = "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity"

# 1. Remove corrupted PNG files that are causing warnings
Write-Host "Removing corrupted screenshot files..." -ForegroundColor Yellow
$corruptPngs = @(
    "$projectPath\assets\imported\temp\ancienttemple\Ancient Temple\Saved\AutoScreenshot.png",
    "$projectPath\assets\imported\temp\ancientruins\Ancient Ruins\Saved\AutoScreenshot.png",
    "$projectPath\assets\imported\temp\arabianpalace\Arabian Palace\Saved\AutoScreenshot.png",
    "$projectPath\assets\imported\temp\medievaltown\Stylized Medieval Town\Saved\AutoScreenshot.png",
    "$projectPath\assets\imported\temp\medievalvillage\Stylized Medieval Village\Saved\AutoScreenshot.png"
)

foreach ($file in $corruptPngs) {
    if (Test-Path $file) {
        Remove-Item $file -Force
        Write-Host "Removed: $file" -ForegroundColor Green
    }
}

# 2. Find and copy texture files for the column
Write-Host "`nSearching for column textures..." -ForegroundColor Yellow
$textureFiles = Get-ChildItem -Path "$projectPath\assets\imported\temp\ancienttemple" -Recurse -Include "*.tga","*.png","*.jpg" | Where-Object { $_.Name -match "Column|Pilar" }

foreach ($texture in $textureFiles) {
    $destPath = "$projectPath\assets\textures\biblical\$($texture.Name)"
    Copy-Item -Path $texture.FullName -Destination $destPath -Force
    Write-Host "Copied texture: $($texture.Name)" -ForegroundColor Green
}

# 3. Create a simple material for the column if no textures found
if ($textureFiles.Count -eq 0) {
    Write-Host "No textures found. Column will use basic material." -ForegroundColor Yellow
}

Write-Host "`nTexture fix completed!" -ForegroundColor Green