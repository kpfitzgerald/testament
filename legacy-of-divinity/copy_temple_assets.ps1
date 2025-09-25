# Copy temple assets to Godot project
Write-Host "Copying temple assets..." -ForegroundColor Cyan

# Find and copy the temple column
$sourceFile = Get-ChildItem -Path "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity\assets\imported\temp\ancienttemple" -Recurse -Filter "SM_A_Column1_Low_001.FBX" | Select-Object -First 1

if ($sourceFile) {
    $destPath = "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity\assets\models\biblical\temple_column.fbx"
    Copy-Item -Path $sourceFile.FullName -Destination $destPath -Force
    Write-Host "Copied: $($sourceFile.Name) -> temple_column.fbx" -ForegroundColor Green
} else {
    Write-Host "Temple column not found" -ForegroundColor Red
}

# Find any other FBX files
Write-Host "`nSearching for additional models..." -ForegroundColor Yellow
Get-ChildItem -Path "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity\assets\imported\temp" -Recurse -Filter "*.FBX" | ForEach-Object {
    Write-Host "Found: $($_.Name) in $($_.Directory)" -ForegroundColor Magenta
}

Write-Host "`nAssets ready for Godot import!" -ForegroundColor Green