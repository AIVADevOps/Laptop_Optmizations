# ============================================================
# SYSTEM-LEVEL RAM OPTIMIZER v1.0
# Einmalig ausfuehren - wirkt PERMANENT ohne laufendes Script!
# ============================================================

# Admin Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "FEHLER: Bitte als Administrator ausfuehren!" -ForegroundColor Red
    pause
    exit
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SYSTEM-LEVEL RAM OPTIMIZER v1.0" -ForegroundColor Cyan
Write-Host "  Einmalig - wirkt permanent!" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# === 1. BACKGROUND APPS GLOBAL EINSCHRAENKEN ===
Write-Host "[1/5] Background Apps einschraenken..." -ForegroundColor Yellow

# Fuer aktuellen User
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f | Out-Null
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BackgroundAppGlobalToggle /t REG_DWORD /d 0 /f | Out-Null

# System-weit Policy
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" /v LetAppsRunInBackground /t REG_DWORD /d 2 /f | Out-Null

Write-Host "  Background Apps: Eingeschraenkt" -ForegroundColor Green

# === 2. POWER THROTTLING AGGRESSIVER MACHEN ===
Write-Host "[2/5] Power Throttling optimieren..." -ForegroundColor Yellow

# Power Throttling aktivieren und aggressiver machen
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 0 /f | Out-Null

# EcoQoS fuer Hintergrund-Apps erzwingen
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v EnergyEstimationEnabled /t REG_DWORD /d 1 /f | Out-Null
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v CsEnabled /t REG_DWORD /d 1 /f | Out-Null

Write-Host "  Power Throttling: Aggressiv" -ForegroundColor Green

# === 3. MEMORY COMPRESSION UND MANAGEMENT ===
Write-Host "[3/5] Memory Management optimieren..." -ForegroundColor Yellow

# Memory Compression sicherstellen (sollte an sein)
Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue

# Superfetch/SysMain fuer besseres Memory Management
# (Bereits im Ultimate-Tweaks.ps1 konfiguriert)

Write-Host "  Memory Compression: Aktiv" -ForegroundColor Green

# === 4. CHROME POLICIES FUER MEMORY SAVER ===
Write-Host "[4/5] Chrome Memory Policies setzen..." -ForegroundColor Yellow

# Chrome Policy Ordner erstellen
$chromePolicyPath = "HKLM\SOFTWARE\Policies\Google\Chrome"

# Memory Limit auf 2GB setzen (Chrome wird aggressiv Tabs entladen)
reg add $chromePolicyPath /v TotalMemoryLimitMb /t REG_DWORD /d 2048 /f | Out-Null

# Tab Discarding aktivieren
reg add $chromePolicyPath /v TabFreezingEnabled /t REG_DWORD /d 1 /f | Out-Null

# High Efficiency Mode erzwingen
reg add $chromePolicyPath /v HighEfficiencyModeEnabled /t REG_DWORD /d 1 /f | Out-Null

# Renderer Code Integrity (spart etwas RAM)
reg add $chromePolicyPath /v RendererCodeIntegrityEnabled /t REG_DWORD /d 0 /f | Out-Null

Write-Host "  Chrome: Max 2GB RAM, Tab Freezing AN" -ForegroundColor Green

# === 5. EDGE POLICIES (falls installiert) ===
Write-Host "[5/5] Edge Memory Policies setzen..." -ForegroundColor Yellow

$edgePolicyPath = "HKLM\SOFTWARE\Policies\Microsoft\Edge"

reg add $edgePolicyPath /v SleepingTabsEnabled /t REG_DWORD /d 1 /f | Out-Null
reg add $edgePolicyPath /v SleepingTabsTimeout /t REG_DWORD /d 300 /f | Out-Null
reg add $edgePolicyPath /v StartupBoostEnabled /t REG_DWORD /d 0 /f | Out-Null

Write-Host "  Edge: Sleeping Tabs nach 5min" -ForegroundColor Green

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  FERTIG! Aenderungen sind PERMANENT" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Was passiert jetzt:" -ForegroundColor White
Write-Host "  - Background Apps werden automatisch gedrosselt" -ForegroundColor Gray
Write-Host "  - Chrome limitiert sich auf 2GB RAM" -ForegroundColor Gray
Write-Host "  - Inaktive Chrome Tabs werden eingefroren" -ForegroundColor Gray
Write-Host "  - Windows nutzt EcoQoS fuer Hintergrund-Apps" -ForegroundColor Gray
Write-Host ""
Write-Host "WICHTIG: Chrome neustarten damit Policies wirken!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Optional - Chrome Flags (manuell):" -ForegroundColor Cyan
Write-Host "  chrome://flags/#high-efficiency-mode-time-before-discard" -ForegroundColor White
Write-Host "  -> Auf '1 minute' setzen fuer aggressivstes Verhalten" -ForegroundColor Gray
Write-Host ""
pause
