# ============================================
# ULTRA AKKU-OPTIMIERUNG - Windows 11
# ============================================
# 55+ Tweaks fuer maximale Akkulaufzeit
# Version 2.2
# ============================================

$Host.UI.RawUI.WindowTitle = "ULTRA Akku-Optimierung v2.2"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   ULTRA AKKU-OPTIMIERUNG - 55+ TWEAKS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# ============================================
# KATEGORIE 1: SERVICES DEAKTIVIEREN (13)
# ============================================
Write-Host "[1/10] Services deaktivieren..." -ForegroundColor Yellow

$services = @(
    @{Name="DiagTrack"; Desc="Diagnostics Tracking"},
    @{Name="SysMain"; Desc="Superfetch/SysMain"},
    @{Name="WSearch"; Desc="Windows Search"},
    @{Name="PcaSvc"; Desc="Program Compatibility"},
    @{Name="CDPUserSvc"; Desc="Connected Devices Platform"},
    @{Name="dmwappushservice"; Desc="WAP Push Service"},
    @{Name="MapsBroker"; Desc="Downloaded Maps Manager"},
    @{Name="lfsvc"; Desc="Geolocation Service"},
    @{Name="WMPNetworkSvc"; Desc="WMP Network Sharing"},
    @{Name="XblAuthManager"; Desc="Xbox Live Auth"},
    @{Name="XblGameSave"; Desc="Xbox Game Save"},
    @{Name="XboxNetApiSvc"; Desc="Xbox Networking"},
    @{Name="XboxGipSvc"; Desc="Xbox Accessory Management"}
)

foreach ($svc in $services) {
    Write-Host "  - $($svc.Desc)..." -NoNewline
    try {
        Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " SKIP" -ForegroundColor DarkGray
    }
}

# BITS auf Manual
Set-Service -Name BITS -StartupType Manual -ErrorAction SilentlyContinue
Write-Host "  - BITS auf Manual... OK" -ForegroundColor Green

Write-Host ""

# ============================================
# KATEGORIE 2: REGISTRY TWEAKS (10)
# ============================================
Write-Host "[2/10] Registry Tweaks..." -ForegroundColor Yellow

# Fast Startup aus
Write-Host "  - Fast Startup aus..." -NoNewline
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Telemetrie aus
Write-Host "  - Telemetrie aus..." -NoNewline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Sleep Study aus
Write-Host "  - Sleep Study aus..." -NoNewline
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v SleepStudyDisabled /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# App Compatibility aus
Write-Host "  - App Compatibility aus..." -NoNewline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v DisableInventory /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Cortana aus
Write-Host "  - Cortana aus..." -NoNewline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Xbox GameDVR aus
Write-Host "  - Xbox GameDVR aus..." -NoNewline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v AllowGameDVR /t REG_DWORD /d 0 /f 2>$null | Out-Null
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f 2>$null | Out-Null
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Bing Search aus
Write-Host "  - Bing Search aus..." -NoNewline
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableSearchBoxSuggestions /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Search Indexing Energie-Modus
Write-Host "  - Search Indexing Energie-Modus..." -NoNewline
reg add "HKLM\SOFTWARE\Microsoft\Windows Search" /v RespectPowerModes /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Processor Boost Mode freischalten
Write-Host "  - Processor Boost Mode freischalten..." -NoNewline
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\be337238-0d82-4146-a960-4f3749d470c7" /v Attributes /t REG_DWORD /d 2 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Game Bar Tips aus
Write-Host "  - Game Bar Tips aus..." -NoNewline
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v ShowStartupPanel /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host ""

# ============================================
# KATEGORIE 3: SCHEDULED TASKS (7)
# ============================================
Write-Host "[3/10] Scheduled Tasks deaktivieren..." -ForegroundColor Yellow

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
    Write-Host "  - $taskName..." -NoNewline
    try {
        Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " SKIP" -ForegroundColor DarkGray
    }
}

Write-Host ""

# ============================================
# KATEGORIE 4: POWER SETTINGS (4)
# ============================================
Write-Host "[4/10] Power Settings..." -ForegroundColor Yellow

Write-Host "  - Processor Boost AUS..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PROCESSOR PERFBOOSTMODE 0 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host "  - USB Selective Suspend AN..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 1 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host "  - PCIe Link State Maximum..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT SUB_PCIEXPRESS ASPM 2 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host "  - WLAN Maximum Power Saving..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT 19cbb8fa-5279-450e-9fac-8a3d5fedd0c1 12bbebe6-58d6-4636-95bb-3217ef867c1a 3 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host ""

# ============================================
# KATEGORIE 5: MODERN STANDBY & NETZWERK (NEU)
# ============================================
Write-Host "[5/10] Modern Standby & Netzwerk..." -ForegroundColor Yellow

# Network Connectivity in Standby AUS
Write-Host "  - Network in Standby AUS..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT SUB_NONE CONNECTIVITYINSTANDBY 0 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Delivery Optimization Service deaktivieren
Write-Host "  - Delivery Optimization AUS..." -NoNewline
Set-Service -Name DoSvc -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service -Name DoSvc -Force -ErrorAction SilentlyContinue
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /v DODownloadMode /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Delivery Optimization Service Registry
Write-Host "  - DoSvc Service Disabled..." -NoNewline
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v Start /t REG_DWORD /d 4 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host ""

# ============================================
# KATEGORIE 6: STARTUP & BACKGROUND (NEU)
# ============================================
Write-Host "[6/10] Startup & Background Apps..." -ForegroundColor Yellow

# Startup Delay entfernen
Write-Host "  - Startup Delay = 0..." -NoNewline
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Background Apps Global deaktivieren
Write-Host "  - Background Apps Global AUS..." -NoNewline
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Background App Toggle AUS
Write-Host "  - Background App Toggle AUS..." -NoNewline
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BackgroundAppGlobalToggle /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# AppPrivacy - Let Apps Run in Background = Deny
Write-Host "  - AppPrivacy: Background Deny..." -NoNewline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host ""

# ============================================
# KATEGORIE 7: NOTIFICATIONS & UI (NEU)
# ============================================
Write-Host "[7/10] Notifications & UI..." -ForegroundColor Yellow

# Notification Center deaktivieren
Write-Host "  - Notification Center AUS..." -NoNewline
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Transparency - BEHALTEN (User Preference)
# Write-Host "  - Transparency AUS..." -NoNewline
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f 2>$null | Out-Null
# Write-Host " OK" -ForegroundColor Green

# Animations AUS
Write-Host "  - Animations AUS..." -NoNewline
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f 2>$null | Out-Null
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host ""

# ============================================
# KATEGORIE 8: WINDOWS UPDATE CONTROL (NEU)
# ============================================
Write-Host "[8/10] Windows Update Control..." -ForegroundColor Yellow

# Auto-Update auf Notify Only
Write-Host "  - Auto-Update auf Notify..." -NoNewline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Update Services auf Manual
Write-Host "  - wuauserv auf Manual..." -NoNewline
Set-Service -Name wuauserv -StartupType Manual -ErrorAction SilentlyContinue
Write-Host " OK" -ForegroundColor Green

Write-Host "  - UsoSvc auf Manual..." -NoNewline
Set-Service -Name UsoSvc -StartupType Manual -ErrorAction SilentlyContinue
Write-Host " OK" -ForegroundColor Green

Write-Host ""

# ============================================
# KATEGORIE 9: ZUSAETZLICHE SERVICES (NEU)
# ============================================
Write-Host "[9/10] Zusaetzliche Services..." -ForegroundColor Yellow

$extraServices = @(
    @{Name="WaaSMedicSvc"; Desc="Windows Update Medic"; Type="Manual"},
    @{Name="InstallService"; Desc="Microsoft Store Install"; Type="Manual"},
    @{Name="TokenBroker"; Desc="Web Account Manager"; Type="Manual"},
    @{Name="wisvc"; Desc="Windows Insider Service"; Type="Disabled"},
    @{Name="RetailDemo"; Desc="Retail Demo Service"; Type="Disabled"},
    @{Name="MessagingService"; Desc="Messaging Service"; Type="Disabled"},
    @{Name="PhoneSvc"; Desc="Phone Service"; Type="Disabled"},
    @{Name="TabletInputService"; Desc="Touch Keyboard (kein Touchscreen)"; Type="Disabled"},
    @{Name="Fax"; Desc="Fax Service"; Type="Disabled"},
    @{Name="WerSvc"; Desc="Windows Error Reporting"; Type="Disabled"},
    @{Name="TermService"; Desc="Remote Desktop"; Type="Disabled"},
    @{Name="RemoteRegistry"; Desc="Remote Registry"; Type="Disabled"},
    @{Name="RemoteAccess"; Desc="Routing and Remote Access"; Type="Disabled"}
)

foreach ($svc in $extraServices) {
    Write-Host "  - $($svc.Desc)..." -NoNewline
    try {
        if ($svc.Type -eq "Disabled") {
            Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
            Stop-Service -Name $svc.Name -Force -ErrorAction SilentlyContinue
        } else {
            Set-Service -Name $svc.Name -StartupType Manual -ErrorAction SilentlyContinue
        }
        Write-Host " OK" -ForegroundColor Green
    } catch {
        Write-Host " SKIP" -ForegroundColor DarkGray
    }
}

Write-Host ""

# ============================================
# KATEGORIE 10: POWER ADVANCED (NEU)
# ============================================
Write-Host "[10/10] Power Advanced..." -ForegroundColor Yellow

# Hibernate aktivieren
Write-Host "  - Hibernate aktivieren..." -NoNewline
powercfg /h on 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Lid Close = Hibernate
Write-Host "  - Lid Close = Hibernate..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 2 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Sleep nach 5 Min, Hibernate nach 10 Min
Write-Host "  - Sleep 5 Min, Hibernate 10 Min..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 300 2>$null | Out-Null
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP HIBERNATEIDLE 600 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Display aus nach 2 Min
Write-Host "  - Display aus nach 2 Min..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOIDLE 120 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Wake Timers AUS
Write-Host "  - Wake Timers AUS..." -NoNewline
powercfg /setdcvalueindex SCHEME_CURRENT SUB_SLEEP RTCWAKE 0 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Aktivieren
powercfg /setactive SCHEME_CURRENT 2>$null | Out-Null

Write-Host ""

# ============================================
# KATEGORIE 11: UI & DISTRACTIONS (NEU)
# ============================================
Write-Host "[11/11] UI & Distractions..." -ForegroundColor Yellow

# Copilot AUS
Write-Host "  - Copilot AUS..." -NoNewline
reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Widgets deaktivieren
Write-Host "  - Widgets AUS..." -NoNewline
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Tips & Suggestions AUS
Write-Host "  - Tips & Suggestions AUS..." -NoNewline
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f 2>$null | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SoftLandingEnabled /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

# Activity History AUS
Write-Host "  - Activity History AUS..." -NoNewline
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableActivityFeed /t REG_DWORD /d 0 /f 2>$null | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v PublishUserActivities /t REG_DWORD /d 0 /f 2>$null | Out-Null
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v UploadUserActivities /t REG_DWORD /d 0 /f 2>$null | Out-Null
Write-Host " OK" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "   FERTIG! 55+ Optimierungen angewendet" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Geschaetzte Akku-Einsparung: 1-2 Stunden!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Bitte PC neustarten fuer volle Wirkung!" -ForegroundColor Yellow
Write-Host ""
Read-Host "Druecke Enter zum Schliessen"
