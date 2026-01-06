Write-Host "=== SYSTEM STATUS ===" -ForegroundColor Cyan
Write-Host ""

# CPU
$cpu = Get-CimInstance Win32_Processor
Write-Host "CPU: $($cpu.Name)" -ForegroundColor White
Write-Host "  Clock: $($cpu.CurrentClockSpeed) MHz (Max: $($cpu.MaxClockSpeed) MHz)"
Write-Host "  Load: $($cpu.LoadPercentage)%"
Write-Host ""

# RAM
$os = Get-CimInstance Win32_OperatingSystem
$totalGB = [math]::Round($os.TotalVisibleMemorySize/1MB, 1)
$freeGB = [math]::Round($os.FreePhysicalMemory/1MB, 1)
$usedGB = [math]::Round($totalGB - $freeGB, 1)
$pct = [math]::Round(($usedGB/$totalGB)*100, 1)
Write-Host "RAM: $usedGB GB / $totalGB GB ($pct%)" -ForegroundColor White
Write-Host ""

# Battery
$bat = Get-CimInstance Win32_Battery
Write-Host "Akku: $($bat.EstimatedChargeRemaining)%" -ForegroundColor White
Write-Host "  Restlaufzeit: $($bat.EstimatedRunTime) Minuten"
Write-Host ""

# Top RAM Prozesse
Write-Host "Top 5 RAM-Verbraucher:" -ForegroundColor Yellow
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 | ForEach-Object {
    $mb = [math]::Round($_.WorkingSet64/1MB)
    Write-Host "  $($_.ProcessName): $mb MB"
}
