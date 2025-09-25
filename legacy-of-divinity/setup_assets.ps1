# Legacy of Divinity - Asset Setup Script
# This script creates the asset directory structure and extracts key biblical assets

$ProjectPath = "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity"
$AssetPath = "$ProjectPath\assets"
$UnrealAssetsPath = "C:\Users\kungf\Dropbox\PC\Downloads\unreal"

Write-Host "Legacy of Divinity - Asset Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Create asset directory structure
Write-Host "Creating asset directories..." -ForegroundColor Yellow

$directories = @(
    "$AssetPath\models\biblical",
    "$AssetPath\models\environment",
    "$AssetPath\models\props",
    "$AssetPath\models\characters",
    "$AssetPath\textures\biblical",
    "$AssetPath\textures\environment",
    "$AssetPath\materials",
    "$AssetPath\audio\music",
    "$AssetPath\audio\sfx",
    "$AssetPath\cinematics",
    "$AssetPath\imported\temp",
    "$AssetPath\scenes\biblical"
)

foreach ($dir in $directories) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
    Write-Host "Created: $dir" -ForegroundColor Green
}

# Extract biblical asset packs
Write-Host ""
Write-Host "Extracting biblical assets..." -ForegroundColor Yellow

$biblicalAssets = @(
    @{ Name = "ancienttemple"; File = "ancienttemple.zip" },
    @{ Name = "ancientruins"; File = "ancientruins.zip" },
    @{ Name = "arabianpalace"; File = "arabianpalace.zip" },
    @{ Name = "medievaltown"; File = "modularmedievalstylizedtown.zip" },
    @{ Name = "medievalvillage"; File = "modularstylizedmedievalvillage.zip" }
)

foreach ($asset in $biblicalAssets) {
    $zipPath = "$UnrealAssetsPath\$($asset.File)"
    $extractPath = "$AssetPath\imported\temp\$($asset.Name)"

    if (Test-Path $zipPath) {
        Write-Host "Extracting $($asset.Name)..." -ForegroundColor Yellow
        try {
            Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
            Write-Host "Extracted $($asset.Name)" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to extract $($asset.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "Asset not found: $($asset.File)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Asset setup completed!" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Review extracted assets in: $AssetPath\imported\temp" -ForegroundColor White
Write-Host "2. Import 3D models (.fbx) into Godot" -ForegroundColor White
Write-Host "3. Organize textures and materials" -ForegroundColor White

Write-Host ""
Read-Host "Press Enter to continue"