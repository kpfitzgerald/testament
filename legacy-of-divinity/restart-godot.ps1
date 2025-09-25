# Legacy of Divinity - Godot Restart Script
# This script removes the .godot cache folder and reopens the project in Godot

$ProjectPath = "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity"
$GodotFolder = Join-Path $ProjectPath ".godot"

Write-Host "Legacy of Divinity - Godot Restart Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Check if project directory exists
if (-not (Test-Path $ProjectPath)) {
    Write-Host "ERROR: Project directory not found at $ProjectPath" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Close any running Godot processes
Write-Host "Checking for running Godot processes..." -ForegroundColor Yellow
$godotProcesses = Get-Process -Name "Godot*" -ErrorAction SilentlyContinue
if ($godotProcesses) {
    Write-Host "Found running Godot processes. Closing them..." -ForegroundColor Yellow
    $godotProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-Host "Godot processes closed." -ForegroundColor Green
} else {
    Write-Host "No running Godot processes found." -ForegroundColor Green
}

# Remove .godot folder if it exists
if (Test-Path $GodotFolder) {
    Write-Host "Removing .godot cache folder..." -ForegroundColor Yellow
    try {
        Remove-Item $GodotFolder -Recurse -Force
        Write-Host ".godot folder removed successfully." -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Could not remove .godot folder: $($_.Exception.Message)" -ForegroundColor Red
        Read-Host "Press Enter to continue anyway"
    }
} else {
    Write-Host ".godot folder not found (already clean)." -ForegroundColor Green
}

# Find Godot executable
Write-Host "Looking for Godot executable..." -ForegroundColor Yellow

# Common Godot installation paths (prioritize GUI version over console)
$godotPaths = @(
    "$ProjectPath\Godot_v4.5-stable_win64.exe",
    "C:\Program Files\Godot\Godot.exe",
    "C:\Program Files (x86)\Godot\Godot.exe",
    "$env:LOCALAPPDATA\Programs\Godot\Godot.exe",
    "C:\Godot\Godot.exe",
    "$env:USERPROFILE\Desktop\Godot.exe",
    "$env:USERPROFILE\Downloads\Godot.exe",
    "$ProjectPath\Godot_v4.5-stable_win64_console.exe"
)

$godotExe = $null
foreach ($path in $godotPaths) {
    if (Test-Path $path) {
        $godotExe = $path
        break
    }
}

# If not found in common paths, try to find it
if (-not $godotExe) {
    Write-Host "Godot not found in common locations. Searching..." -ForegroundColor Yellow

    # Search in Program Files
    $foundGodot = Get-ChildItem -Path "C:\Program Files*" -Name "Godot*" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Godot*.exe" } | Select-Object -First 1
    if ($foundGodot) {
        $godotExe = $foundGodot.FullName
    }
}

# If still not found, ask user
if (-not $godotExe) {
    Write-Host "Godot executable not found automatically." -ForegroundColor Red
    Write-Host "Please provide the path to Godot.exe (or press Enter to skip opening Godot):" -ForegroundColor Yellow
    $userPath = Read-Host

    if ($userPath -and (Test-Path $userPath)) {
        $godotExe = $userPath
    } else {
        Write-Host "Skipping Godot launch. Project cache cleared successfully." -ForegroundColor Green
        Read-Host "Press Enter to exit"
        exit 0
    }
}

# Launch Godot with the project
if ($godotExe) {
    Write-Host "Found Godot at: $godotExe" -ForegroundColor Green
    Write-Host "Opening Legacy of Divinity project..." -ForegroundColor Yellow

    try {
        # Change to project directory and launch Godot editor
        Set-Location $ProjectPath
        Start-Process -FilePath $godotExe -ArgumentList "--editor", "--path", $ProjectPath
        Write-Host "Godot launched successfully!" -ForegroundColor Green
        Write-Host "Project: Legacy of Divinity" -ForegroundColor Cyan
    }
    catch {
        Write-Host "ERROR: Could not launch Godot: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "You can manually open Godot and import the project from:" -ForegroundColor Yellow
        Write-Host $ProjectPath -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Script completed. Press Enter to exit..." -ForegroundColor Green
Read-Host