# Simple asset finder for biblical assets
$tempPath = "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity\assets\imported\temp"

Write-Host "Searching for usable 3D assets..." -ForegroundColor Cyan

$extensions = @("*.fbx", "*.obj", "*.blend", "*.FBX", "*.OBJ")
$textureExtensions = @("*.png", "*.jpg", "*.tga", "*.PNG", "*.JPG", "*.TGA")

Write-Host "`nAncient Temple Assets:" -ForegroundColor Yellow
Get-ChildItem -Path "$tempPath\ancienttemple" -Recurse -Include $extensions | ForEach-Object {
    Write-Host "  3D Model: $($_.Name)" -ForegroundColor Green
}

Write-Host "`nAncient Ruins Assets:" -ForegroundColor Yellow
Get-ChildItem -Path "$tempPath\ancientruins" -Recurse -Include $extensions | ForEach-Object {
    Write-Host "  3D Model: $($_.Name)" -ForegroundColor Green
}

Write-Host "`nTexture Files:" -ForegroundColor Yellow
Get-ChildItem -Path "$tempPath" -Recurse -Include $textureExtensions | Select-Object -First 10 | ForEach-Object {
    Write-Host "  Texture: $($_.Name)" -ForegroundColor Magenta
}

Write-Host "`nReady to import into Godot!" -ForegroundColor Green