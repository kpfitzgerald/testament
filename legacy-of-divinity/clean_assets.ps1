# Clean up problematic assets that are causing texture errors
Write-Host "Cleaning problematic assets..." -ForegroundColor Cyan

$projectPath = "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity"

# 1. Remove the problematic FBX file that has missing textures
$fbxFile = "$projectPath\assets\models\biblical\temple_column.fbx"
if (Test-Path $fbxFile) {
    Remove-Item $fbxFile -Force
    Write-Host "Removed problematic FBX file: temple_column.fbx" -ForegroundColor Green
}

# 2. Remove the entire temp folder to prevent Godot from scanning it
$tempFolder = "$projectPath\assets\imported\temp"
if (Test-Path $tempFolder) {
    Remove-Item $tempFolder -Recurse -Force
    Write-Host "Removed temp assets folder" -ForegroundColor Green
}

# 3. Remove the old scene files that might reference the FBX
$oldScenes = @(
    "$projectPath\scenes\biblical\TempleCourtyard.tscn",
    "$projectPath\scenes\biblical\SimpleTemple.tscn"
)

foreach ($scene in $oldScenes) {
    if (Test-Path $scene) {
        Remove-Item $scene -Force
        Write-Host "Removed old scene: $(Split-Path $scene -Leaf)" -ForegroundColor Green
    }
}

Write-Host "`nAsset cleanup completed!" -ForegroundColor Green
Write-Host "The biblical world now uses only built-in Godot assets." -ForegroundColor Yellow