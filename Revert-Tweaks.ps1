# ============================================
# ALLE AENDERUNGEN RUECKGAENGIG MACHEN
# ============================================
# Setzt alle 55+ Tweaks zurueck (v2.2)
# ============================================

$Host.UI.RawUI.WindowTitle = "Alles Rueckgaengig v2.2"
Write-Host "============================================" -ForegroundColor Red
Write-Host "   ALLE 55+ AENDERUNGEN RUECKGAENGIG" -ForegroundColor Red
Write-Host "============================================" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Bist du sicher? (j/n)"
if ($confirm -ne 'j') {
    Write-Host "Abgebrochen." -ForegroundColor Yellow
    exit
}

Write-Host ""

# ============================================
# SERVICES WIEDER AKTIVIEREN
# ============================================
Write-Host "[1/10] Services aktivieren..." -ForegroundColor Yellow

$services = @(
    @{Name="DiagTrack"; Start="Automatic"},
    @{Name="SysMain"; Start="Automatic"},
    @{Name="WSearch"; Start="Automatic"},
    @{Name="PcaSvc"; Start="Automatic"},
    @{Name="BITS"; Start="Automatic"},
    @{Name="CDPUserSvc"; Start="Automatic"},
    @{Name="dmwappushservice"; Start="Automatic"},
    @{Name="MapsBroker"; Start="Automatic"},
    @{Name="lfsvc"; Start="Manual"},
    @{Name="WMPNetworkSvc"; Start="Manual"},
    @{Name="XblAuthManager"; Start="Manual"},
    @{Name="XblGameSave"; Start="Manual"},
    @{Name="XboxNetApiSvc"; Start="Manual"},
    @{Name="XboxGipSvc"; Start="Manual"},
    @{Name="DoSvc"; Start="Automatic"},
    @{Name="wuauserv"; Start="Automatic"},
    @{Name="UsoSvc"; Start="Automatic"},
    @{Name="WaaSMedicSvc"; Start="Manual"},
    @{Name="InstallService"; Start="Manual"},
    @{Name="TokenBroker"; Start="Manual"},
    @{Name="wisvc"; Start="Manual"},
    @{Name="RetailDemo"; Start="Manual"},
    @{Name="MessagingService"; Start="Manual"},
    @{Name="PhoneSvc"; Start="Manual"},
    @{Name="TabletInputService"; Start="Manual"},
    @{Name="Fax"; Start="Manual"},
    @{Name="WerSvc"; Start="Manual"},
    @{Name="TermService"; Start="Manual"},
    @{Name="RemoteRegistry"; Start="Disabled"},
    @{Name="RemoteAccess"; Start="Disabled"}
)

foreach ($svc in $services) {
    try {
        Set-Service -Name $svc.Name -StartupType $svc.Start -ErrorAction SilentlyContinue
        Write-Host "  $($svc.Name) -> $($svc.Start)" -ForegroundColor Green
    } catch {}
}

# ============================================
# REGISTRY ZURUECKSETZEN
# ============================================
Write-Host ""
Write-Host "[2/10] Registry zuruecksetzen..." -ForegroundColor Yellow

# Fast Startup an
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host "  Fast Startup -> AN" -ForegroundColor Green

# Telemetrie standard
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f 2>$null
Write-Host "  Telemetrie -> Standard" -ForegroundColor Green

# Sleep Study standard
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v SleepStudyDisabled /f 2>$null
Write-Host "  Sleep Study -> Standard" -ForegroundColor Green

# App Compatibility standard
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableInventory /f 2>$null
Write-Host "  App Compatibility -> Standard" -ForegroundColor Green

# Cortana standard
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /f 2>$null
Write-Host "  Cortana -> Standard" -ForegroundColor Green

# Xbox GameDVR an
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /f 2>$null
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 1 /f 2>$null | Out-Null
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host "  Xbox GameDVR -> AN" -ForegroundColor Green

# Bing Search an
reg delete "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /f 2>$null
Write-Host "  Bing Search -> Standard" -ForegroundColor Green

# Game Bar Tips an
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host "  Game Bar Tips -> AN" -ForegroundColor Green

# ============================================
# NEUE REGISTRY ZURUECKSETZEN
# ============================================
Write-Host ""
Write-Host "[3/10] Neue Registry zuruecksetzen..." -ForegroundColor Yellow

# Delivery Optimization
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /f 2>$null
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 2 /f 2>$null | Out-Null
Write-Host "  Delivery Optimization -> Standard" -ForegroundColor Green

# Startup Delay
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /f 2>$null
Write-Host "  Startup Delay -> Standard" -ForegroundColor Green

# Background Apps
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /f 2>$null
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BackgroundAppGlobalToggle /f 2>$null
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /f 2>$null
Write-Host "  Background Apps -> Standard" -ForegroundColor Green

# Notification Center
reg delete "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /f 2>$null
Write-Host "  Notification Center -> AN" -ForegroundColor Green

# Transparency
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host "  Transparency -> AN" -ForegroundColor Green

# Windows Update
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /f 2>$null
Write-Host "  Windows Update -> Standard" -ForegroundColor Green

# ============================================
# SCHEDULED TASKS AKTIVIEREN
# ============================================
Write-Host ""
Write-Host "[4/10] Scheduled Tasks aktivieren..." -ForegroundColor Yellow

$tasks = @(
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
)

foreach ($task in $tasks) {
    $taskName = $task.Split('\')[-1]
    try {
        Enable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
        Write-Host "  $taskName -> Aktiviert" -ForegroundColor Green
    } catch {}
}

# ============================================
# POWER SETTINGS ZURUECKSETZEN
# ============================================
Write-Host ""
Write-Host "[5/10] Power Settings zuruecksetzen..." -ForegroundColor Yellow

# CPU auf 100%
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100 2>$null | Out-Null
Write-Host "  CPU Max -> 100%" -ForegroundColor Green

# Turbo Boost an
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 2 2>$null | Out-Null
Write-Host "  Turbo Boost -> AN" -ForegroundColor Green

# EPP auf 50%
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFEPP 50 2>$null | Out-Null
Write-Host "  EPP -> 50% (Balanced)" -ForegroundColor Green

# Network in Standby an
powercfg /setdcvalueindex SCHEME_CURRENT SUB_NONE CONNECTIVITYINSTANDBY 1 2>$null | Out-Null
Write-Host "  Network in Standby -> AN" -ForegroundColor Green

# USB Selective Suspend aus
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 2>$null | Out-Null
Write-Host "  USB Selective Suspend -> AUS" -ForegroundColor Green

# PCIe Link State Off
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 0 2>$null | Out-Null
Write-Host "  PCIe Link State -> Off" -ForegroundColor Green

# WLAN Maximum Performance
powercfg /setdcvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 0 2>$null | Out-Null
Write-Host "  WLAN -> Maximum Performance" -ForegroundColor Green

# Wake Timers an
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 1 2>$null | Out-Null
Write-Host "  Wake Timers -> AN" -ForegroundColor Green

# Lid Close = Sleep
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 1 2>$null | Out-Null
Write-Host "  Lid Close -> Sleep" -ForegroundColor Green

# Display/Sleep Timeouts
powercfg /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 300 2>$null | Out-Null
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 600 2>$null | Out-Null
Write-Host "  Display 5 Min, Sleep 10 Min" -ForegroundColor Green

# Aktivieren
powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null

# ============================================
# UI & DISTRACTIONS ZURUECKSETZEN
# ============================================
Write-Host ""
Write-Host "[6/6] UI & Distractions zuruecksetzen..." -ForegroundColor Yellow

# Copilot standard
reg delete "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /f 2>$null
Write-Host "  Copilot -> Standard" -ForegroundColor Green

# Widgets an
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host "  Widgets -> AN" -ForegroundColor Green

# Tips & Suggestions an
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 1 /f 2>$null | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host "  Tips & Suggestions -> AN" -ForegroundColor Green

# Activity History standard
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /f 2>$null
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /f 2>$null
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /f 2>$null
Write-Host "  Activity History -> Standard" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   FERTIG! Alles zurueckgesetzt." -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Bitte PC neustarten!" -ForegroundColor Yellow
Write-Host ""
Read-Host "Druecke Enter zum Schliessen"
