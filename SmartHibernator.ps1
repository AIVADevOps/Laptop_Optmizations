# ============================================================
# SMART PROCESS HIBERNATOR v1.0
# Suspendiert Chrome/ChatGPT wenn nicht im Fokus
# Laesst Dev-Tools (Antigravity, Node, etc.) IMMER laufen
# ============================================================

# Admin Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "FEHLER: Bitte als Administrator ausfuehren!" -ForegroundColor Red
    pause
    exit
}

# === KONFIGURATION ===
$IDLE_TIMEOUT_SECONDS = 30  # Nach X Sekunden Inaktivitaet suspendieren
$CHECK_INTERVAL_MS = 1000   # Alle X ms pruefen

# WHITELIST - Diese Prozesse werden NIE suspendiert
$WHITELIST = @(
    "antigravity",
    "code",           # VS Code
    "node",
    "npm",
    "npx",
    "python",
    "python3",
    "powershell",
    "pwsh",
    "cmd",
    "WindowsTerminal",
    "wt",
    "git",
    "ssh",
    "explorer",       # Windows Explorer
    "SearchHost",
    "StartMenuExperienceHost",
    "ShellExperienceHost",
    "RuntimeBroker",
    "dwm",            # Desktop Window Manager
    "csrss",
    "smss",
    "services",
    "svchost",
    "System",
    "Idle",
    "HWiNFO64"
)

# SUSPEND-LISTE - Diese Prozesse werden suspendiert wenn nicht im Fokus
$SUSPEND_TARGETS = @(
    "chrome",
    "msedge",
    "firefox",
    "chatgpt",
    "teams",
    "slack",
    "discord",
    "spotify",
    "WhatsApp"
)

# === WINDOWS API FUNKTIONEN ===
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Diagnostics;

public class ProcessManager {
    [DllImport("ntdll.dll", SetLastError = true)]
    private static extern int NtSuspendProcess(IntPtr processHandle);

    [DllImport("ntdll.dll", SetLastError = true)]
    private static extern int NtResumeProcess(IntPtr processHandle);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr OpenProcess(int access, bool inheritHandle, int processId);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern bool CloseHandle(IntPtr handle);

    [DllImport("psapi.dll", SetLastError = true)]
    private static extern bool EmptyWorkingSet(IntPtr processHandle);

    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out int processId);

    private const int PROCESS_SUSPEND_RESUME = 0x0800;
    private const int PROCESS_QUERY_INFORMATION = 0x0400;
    private const int PROCESS_SET_QUOTA = 0x0100;
    private const int PROCESS_ALL_ACCESS = 0x1F0FFF;

    public static bool SuspendProcess(int pid) {
        IntPtr handle = OpenProcess(PROCESS_SUSPEND_RESUME, false, pid);
        if (handle == IntPtr.Zero) return false;
        int result = NtSuspendProcess(handle);
        CloseHandle(handle);
        return result == 0;
    }

    public static bool ResumeProcess(int pid) {
        IntPtr handle = OpenProcess(PROCESS_SUSPEND_RESUME, false, pid);
        if (handle == IntPtr.Zero) return false;
        int result = NtResumeProcess(handle);
        CloseHandle(handle);
        return result == 0;
    }

    public static bool TrimMemory(int pid) {
        IntPtr handle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_SET_QUOTA, false, pid);
        if (handle == IntPtr.Zero) return false;
        bool result = EmptyWorkingSet(handle);
        CloseHandle(handle);
        return result;
    }

    public static int GetForegroundProcessId() {
        IntPtr hwnd = GetForegroundWindow();
        int pid;
        GetWindowThreadProcessId(hwnd, out pid);
        return pid;
    }
}
"@

# === GLOBALE VARIABLEN ===
$script:suspendedProcesses = @{}  # PID -> Zeitpunkt
$script:lastFocusTime = @{}       # ProcessName -> Letzter Fokus
$script:running = $true

# === FUNKTIONEN ===
function Get-ForegroundProcessName {
    try {
        $pid = [ProcessManager]::GetForegroundProcessId()
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        return $proc.ProcessName
    } catch {
        return $null
    }
}

function Is-Whitelisted($processName) {
    return $WHITELIST -contains $processName.ToLower()
}

function Is-SuspendTarget($processName) {
    foreach ($target in $SUSPEND_TARGETS) {
        if ($processName.ToLower() -like "*$target*") {
            return $true
        }
    }
    return $false
}

function Suspend-TargetProcesses($exceptProcessName) {
    foreach ($target in $SUSPEND_TARGETS) {
        $procs = Get-Process -Name "*$target*" -ErrorAction SilentlyContinue
        foreach ($proc in $procs) {
            if ($proc.ProcessName -ne $exceptProcessName -and -not $script:suspendedProcesses.ContainsKey($proc.Id)) {
                $lastFocus = $script:lastFocusTime[$proc.ProcessName]
                $idleTime = (Get-Date) - $lastFocus

                if ($idleTime.TotalSeconds -ge $IDLE_TIMEOUT_SECONDS) {
                    Write-Host "  [SUSPEND] $($proc.ProcessName) (PID: $($proc.Id)) - Idle: $([int]$idleTime.TotalSeconds)s" -ForegroundColor Yellow
                    if ([ProcessManager]::SuspendProcess($proc.Id)) {
                        $script:suspendedProcesses[$proc.Id] = $proc.ProcessName
                    }
                }
            }
        }
    }
}

function Resume-ProcessByName($processName) {
    $toRemove = @()
    foreach ($entry in $script:suspendedProcesses.GetEnumerator()) {
        if ($entry.Value -like "*$processName*") {
            Write-Host "  [RESUME] $($entry.Value) (PID: $($entry.Key))" -ForegroundColor Green
            [ProcessManager]::ResumeProcess($entry.Key) | Out-Null
            $toRemove += $entry.Key
        }
    }
    foreach ($pid in $toRemove) {
        $script:suspendedProcesses.Remove($pid)
    }
}

function Trim-BackgroundMemory {
    $trimmed = 0
    $procs = Get-Process | Where-Object {
        $_.WorkingSet64 -gt 100MB -and
        -not (Is-Whitelisted $_.ProcessName) -and
        -not $script:suspendedProcesses.ContainsKey($_.Id)
    }

    foreach ($proc in $procs) {
        if ([ProcessManager]::TrimMemory($proc.Id)) {
            $trimmed++
        }
    }
    return $trimmed
}

# === CLEANUP HANDLER ===
$null = Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    Write-Host "`nBeende... Resumiere alle suspendierten Prozesse..." -ForegroundColor Cyan
    foreach ($entry in $script:suspendedProcesses.GetEnumerator()) {
        [ProcessManager]::ResumeProcess($entry.Key) | Out-Null
        Write-Host "  Resumed: $($entry.Value)" -ForegroundColor Green
    }
}

# === HAUPTSCHLEIFE ===
Clear-Host
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SMART PROCESS HIBERNATOR v1.0" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Einstellungen:" -ForegroundColor White
Write-Host "  Idle-Timeout: $IDLE_TIMEOUT_SECONDS Sekunden" -ForegroundColor Gray
Write-Host "  Check-Intervall: $CHECK_INTERVAL_MS ms" -ForegroundColor Gray
Write-Host ""
Write-Host "Whitelist (nie suspendieren):" -ForegroundColor White
Write-Host "  antigravity, code, node, npm, python, terminal..." -ForegroundColor Gray
Write-Host ""
Write-Host "Suspend-Ziele:" -ForegroundColor White
Write-Host "  chrome, chatgpt, teams, slack, discord, spotify..." -ForegroundColor Gray
Write-Host ""
Write-Host "Druecke Ctrl+C zum Beenden" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Initialisiere lastFocusTime fuer alle Prozesse
foreach ($target in $SUSPEND_TARGETS) {
    $procs = Get-Process -Name "*$target*" -ErrorAction SilentlyContinue
    foreach ($proc in $procs) {
        $script:lastFocusTime[$proc.ProcessName] = Get-Date
    }
}

$lastTrim = Get-Date
$lastForeground = ""
$statsInterval = 0

try {
    while ($script:running) {
        $currentForeground = Get-ForegroundProcessName

        if ($currentForeground -and $currentForeground -ne $lastForeground) {
            # Fenster gewechselt
            Write-Host "[FOKUS] $currentForeground" -ForegroundColor Cyan

            # Update lastFocusTime
            $script:lastFocusTime[$currentForeground] = Get-Date

            # Resume wenn es ein Suspend-Target ist
            if (Is-SuspendTarget $currentForeground) {
                Resume-ProcessByName $currentForeground
            }

            $lastForeground = $currentForeground
        }

        # Pruefe ob Targets suspendiert werden sollen
        Suspend-TargetProcesses $currentForeground

        # RAM Trim alle 60 Sekunden
        if (((Get-Date) - $lastTrim).TotalSeconds -ge 60) {
            $trimCount = Trim-BackgroundMemory
            if ($trimCount -gt 0) {
                Write-Host "[TRIM] RAM freigegeben von $trimCount Prozessen" -ForegroundColor Magenta
            }
            $lastTrim = Get-Date
        }

        # Status alle 30 Sekunden
        $statsInterval++
        if ($statsInterval -ge 30) {
            $suspendCount = $script:suspendedProcesses.Count
            if ($suspendCount -gt 0) {
                Write-Host "[STATUS] $suspendCount Prozesse suspendiert" -ForegroundColor DarkGray
            }
            $statsInterval = 0
        }

        Start-Sleep -Milliseconds $CHECK_INTERVAL_MS
    }
} finally {
    # Cleanup - Resume alle
    Write-Host "`nBeende... Resumiere alle suspendierten Prozesse..." -ForegroundColor Cyan
    foreach ($entry in $script:suspendedProcesses.GetEnumerator()) {
        [ProcessManager]::ResumeProcess($entry.Key) | Out-Null
        Write-Host "  Resumed: $($entry.Value)" -ForegroundColor Green
    }
    Write-Host "Fertig!" -ForegroundColor Green
}
