# Legacy of Divinity - Godot Restart Script
# This script removes the .godot cache folder and reopens the project in Godot
# Usage: .\restart-godot.ps1 [-Background] [-NoLog]

param(
    [switch]$Background,  # Run Godot in background (don't wait for exit)
    [switch]$NoLog       # Skip logging to file
)

$ProjectPath = "C:\Users\kungf\OneDrive\Documents\git\testament\legacy-of-divinity"
$GodotFolder = Join-Path $ProjectPath ".godot"
$LogFile = Join-Path $ProjectPath "logs\godot-restart.log"

# Create logs directory if it doesn't exist
if (-not $NoLog) {
    $LogDir = Join-Path $ProjectPath "logs"
    if (-not (Test-Path $LogDir)) {
        New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
    }
}

# Function to write both to console and log
function Write-LogHost {
    param(
        [string]$Message,
        [string]$ForegroundColor = "White"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"

    Write-Host $Message -ForegroundColor $ForegroundColor

    if (-not $NoLog) {
        Add-Content -Path $LogFile -Value $logMessage -Encoding UTF8
    }
}

Write-LogHost "Legacy of Divinity - Godot Restart Script" "Cyan"
Write-LogHost "=========================================" "Cyan"

if ($Background) {
    Write-LogHost "Running in background mode - will not wait for Godot to exit" "Yellow"
}

if (-not $NoLog) {
    Write-LogHost "Logging to: $LogFile" "Gray"
}

# Check if project directory exists
if (-not (Test-Path $ProjectPath)) {
    Write-LogHost "ERROR: Project directory not found at $ProjectPath" "Red"
    if (-not $Background) {
        Read-Host "Press Enter to exit"
    }
    exit 1
}

# Close any running Godot processes
Write-LogHost "Checking for running Godot processes..." "Yellow"
$godotProcesses = Get-Process -Name "Godot*" -ErrorAction SilentlyContinue
if ($godotProcesses) {
    Write-LogHost "Found running Godot processes. Closing them..." "Yellow"
    $godotProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
    Write-LogHost "Godot processes closed." "Green"
} else {
    Write-LogHost "No running Godot processes found." "Green"
}

# Remove .godot folder if it exists
if (Test-Path $GodotFolder) {
    Write-LogHost "Removing .godot cache folder..." "Yellow"
    try {
        Remove-Item $GodotFolder -Recurse -Force
        Write-LogHost ".godot folder removed successfully." "Green"
    }
    catch {
        Write-LogHost "ERROR: Could not remove .godot folder: $($_.Exception.Message)" "Red"
        if (-not $Background) {
            Read-Host "Press Enter to continue anyway"
        }
    }
} else {
    Write-LogHost ".godot folder not found (already clean)." "Green"
}

# Find Godot executable
Write-LogHost "Looking for Godot executable..." "Yellow"

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
    Write-LogHost "Godot not found in common locations. Searching..." "Yellow"

    # Search in Program Files
    $foundGodot = Get-ChildItem -Path "C:\Program Files*" -Name "Godot*" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Godot*.exe" } | Select-Object -First 1
    if ($foundGodot) {
        $godotExe = $foundGodot.FullName
    }
}

# If still not found, ask user (only if not in background mode)
if (-not $godotExe) {
    Write-LogHost "Godot executable not found automatically." "Red"
    if ($Background) {
        Write-LogHost "Background mode: Skipping Godot launch. Project cache cleared successfully." "Green"
        exit 0
    } else {
        Write-LogHost "Please provide the path to Godot.exe (or press Enter to skip opening Godot):" "Yellow"
        $userPath = Read-Host

        if ($userPath -and (Test-Path $userPath)) {
            $godotExe = $userPath
        } else {
            Write-LogHost "Skipping Godot launch. Project cache cleared successfully." "Green"
            Read-Host "Press Enter to exit"
            exit 0
        }
    }
}

# Launch Godot with the project
if ($godotExe) {
    Write-LogHost "Found Godot at: $godotExe" "Green"
    Write-LogHost "Opening Legacy of Divinity project..." "Yellow"

    try {
        # Change to project directory and launch Godot editor
        Set-Location $ProjectPath

        if ($Background) {
            # Launch in background without waiting
            $process = Start-Process -FilePath $godotExe -ArgumentList "--editor", "--path", $ProjectPath -PassThru -WindowStyle Normal
            Write-LogHost "Godot launched in background (PID: $($process.Id))" "Green"
            Write-LogHost "Project: Legacy of Divinity" "Cyan"
            Write-LogHost "Script completed - Godot is running in background." "Green"
        } else {
            # Launch normally and wait for user input
            Start-Process -FilePath $godotExe -ArgumentList "--editor", "--path", $ProjectPath
            Write-LogHost "Godot launched successfully!" "Green"
            Write-LogHost "Project: Legacy of Divinity" "Cyan"
        }
    }
    catch {
        Write-LogHost "ERROR: Could not launch Godot: $($_.Exception.Message)" "Red"
        Write-LogHost "You can manually open Godot and import the project from:" "Yellow"
        Write-LogHost $ProjectPath "White"
    }
}

if (-not $Background) {
    Write-LogHost ""
    Write-LogHost "Script completed. Press Enter to exit..." "Green"
    Read-Host
}