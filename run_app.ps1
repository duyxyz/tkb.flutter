$SDK_PATH = "C:/Users/PC/AppData/Local/Android/Sdk"
$ADB = "$SDK_PATH/platform-tools/adb.exe"
$EMULATOR = "$SDK_PATH/emulator/emulator.exe"
$PACKAGE_NAME = "com.duyxyz.tkb"
$ACTIVITY_NAME = "com.duyxyz.tkb.MainActivity"

Write-Host "--- Android Auto Run Script ---" -ForegroundColor Cyan

# 1. Check for connected devices
$devices = & $ADB devices
$has_device = $false
foreach ($line in $devices) {
    if ($line -match "\tdevice$") {
        $has_device = $true
        break
    }
}

if (-not $has_device) {
    Write-Host "[!] No devices found. Starting Emulator: Small_Phone..." -ForegroundColor Yellow
    # Start emulator in background
    Start-Process -FilePath $EMULATOR -ArgumentList "-avd", "Small_Phone"
    
    Write-Host "[*] Waiting for device to connect..." -ForegroundColor Yellow
    & $ADB wait-for-device
    
    Write-Host "[*] Waiting for Android to boot (this may take a minute)..." -ForegroundColor Yellow
    $booted = $false
    while (-not $booted) {
        $status = & $ADB shell getprop sys.boot_completed
        if ($status.Trim() -eq "1") {
            $booted = $true
        } else {
            Write-Host "." -NoNewline
            Start-Sleep -Seconds 3
        }
    }
    Write-Host "`n[+] Emulator is ready!" -ForegroundColor Green
} else {
    Write-Host "[+] Device detected. Proceeding to build..." -ForegroundColor Green
}

# 2. Build and Install
Write-Host "[*] Building and Installing App..." -ForegroundColor Cyan
.\gradlew.bat installDebug

if ($LASTEXITCODE -ne 0) {
    Write-Host "[!] Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

# 3. Start Activity
Write-Host "[*] Opening App: $PACKAGE_NAME..." -ForegroundColor Green
& $ADB shell am start -n "$PACKAGE_NAME/$ACTIVITY_NAME"
Write-Host "--- Done ---" -ForegroundColor Cyan
