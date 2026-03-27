$SDK_PATH = "C:/Users/PC/AppData/Local/Android/Sdk"
$ADB = "$SDK_PATH/platform-tools/adb.exe"
$EMULATOR = "$SDK_PATH/emulator/emulator.exe"

Write-Host "[*] Checking for connected devices..." -ForegroundColor Cyan
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
    Start-Process -FilePath $EMULATOR -ArgumentList "-avd", "Small_Phone"
    
    Write-Host "[*] Waiting for device to connect..." -ForegroundColor Yellow
    & $ADB wait-for-device
    
    Write-Host "[*] Waiting for Android to boot..." -ForegroundColor Yellow
    $booted = $false
    while (-not $booted) {
        $status = & $ADB shell getprop sys.boot_completed
        if ($status.Trim() -eq "1") {
            $booted = $true
        } else {
            Start-Sleep -Seconds 3
        }
    }
    Write-Host "[+] Emulator is ready!" -ForegroundColor Green
} else {
    Write-Host "[+] Device detected. Ready to go!" -ForegroundColor Green
}
