# Attribution and Version
$createdDate = Get-Date "2025-01-12"  # Replace this with the creation date of your script
$lastModified = "2025-01-12"          # Update this when you modify the script
$today = Get-Date                     # Get the current date
$elapsedTime = (New-TimeSpan -Start $createdDate -End $today).Days

# Script Header
Write-Host "=========================="
Write-Host "Enrollment Project"
Write-Host "Created by: Erkam Koca"
Write-Host "Version: 2.0.0 (Upgraded)"
Write-Host "Last Modified: $lastModified"
Write-Host "Today's Date: $($today.ToString('yyyy-MM-dd'))"
Write-Host "This script has been running for $elapsedTime days since its creation."

# Display local system uptime on startup
Write-Host "=============================="
Write-Host "System Uptime Information:"
Show-ComputerUptime
Write-Host "=============================="

# Logging Function
function Log-Action {
    param (
        [string]$ActionMessage
    )
    $logPath = "$PSScriptRoot\ScriptLog.txt"
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $ActionMessage"
    Add-Content -Path $logPath -Value $logEntry
}

# Show how long the computer has been awake (local only)
function Show-ComputerUptime {
    try {
        # Retrieve local computer name and last boot time
        $computerName = $env:COMPUTERNAME
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
        $lastBootTime = $osInfo.LastBootUpTime
        $uptime = New-TimeSpan -Start $lastBootTime -End (Get-Date)

        # Display the results
        Write-Host "=============================="
        Write-Host "Computer Name: $computerName"
        Write-Host "Last Boot Time: $($lastBootTime.ToString('yyyy-MM-dd HH:mm:ss'))"
        Write-Host "Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes, $($uptime.Seconds) seconds."
        Write-Host "==============================" -ForegroundColor Yellow

        # Log the action
        Log-Action "Displayed local uptime: Uptime is $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes."
    } catch {
        Write-Host "Error: Unable to retrieve local uptime." -ForegroundColor Red
        Log-Action "Failed to retrieve local uptime."
    }
}

# Display main menu
function Show-Menu {
    Write-Host "`nChoose an option:"
    Write-Host "1. Show Current Power Plan       - Displays the active power plan."
    Write-Host "2. List All Power Plans          - Lists all available power plans."
    Write-Host "3. Change Power Plan             - Switch to another power plan."
    Write-Host "4. Show System Uptime            - Displays the local system's uptime."
    Write-Host "5. Force Group Policy Update     - Runs gpupdate /force."
    Write-Host "6. Trigger Intune Sync           - Initiates a sync with Intune."
    Write-Host "7. Check Work/Domain Status      - Checks the system's domain or work account status."
    Write-Host "8. Perform System Health Check   - Displays system performance details."
    Write-Host "9. Helpful Tools                 - Access useful CMD commands for troubleshooting."
    Write-Host "10. Exit                         - Closes the script."
    $choice = Read-Host "Enter your choice (1-10) or press ESC to return"
    if ($choice -eq '') { return "ESC" }
    return $choice
}

# Power Plan Functions
function Show-CurrentPowerPlan {
    try {
        $currentPlan = powercfg /GETACTIVESCHEME
        Write-Host "Current Power Plan:"
        Write-Host $currentPlan
        Log-Action "Displayed current power plan."
    } catch {
        Write-Host "Error: Unable to retrieve current power plan." -ForegroundColor Red
    }
}

function List-AllPowerPlans {
    try {
        $plans = powercfg /L
        Write-Host "Available Power Plans:"
        Write-Host $plans
        Log-Action "Listed all power plans."
    } catch {
        Write-Host "Error: Unable to list power plans." -ForegroundColor Red
    }
}

function Change-PowerPlan {
    try {
        $plans = powercfg /L
        $planList = @()
        Write-Host "Available Power Plans:"
        $lines = $plans -split "`n"
        $index = 1
        foreach ($line in $lines) {
            if ($line -match "Power Scheme GUID:\s+(.+?)\s+\((.+?)\)(\s+\*\s+)?") {
                $guid = $Matches[1]
                $planName = $Matches[2]
                $isActive = $Matches[3] -ne $null
                $planList += @{ Name = $planName; GUID = $guid; IsActive = $isActive }

                if ($isActive) {
                    Write-Host "$index. $planName (Active)"
                } else {
                    Write-Host "$index. $planName"
                }
                $index++
            }
        }

        $selection = Read-Host "Enter the number of the power plan to activate or press ESC to return"
        if ($selection -eq '') { return }
        if ($selection -match "^\d+$" -and $selection -le $planList.Count -and $selection -gt 0) {
            $selectedPlan = $planList[$selection - 1]
            powercfg /S $selectedPlan.GUID
            Write-Host "Power plan changed to: $($selectedPlan.Name)"
            Log-Action "Changed power plan to $($selectedPlan.Name)."
        } else {
            Write-Host "Invalid selection. Returning to menu."
        }
    } catch {
        Write-Host "Error: Unable to change power plan." -ForegroundColor Red
    }
}

# System Health Check
function System-HealthCheck {
    try {
        Write-Host "Performing System Health Check..."
        $cpuUsage = Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object -ExpandProperty CookedValue
        $memory = Get-CimInstance Win32_OperatingSystem
        $diskSpace = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } | Select-Object Name, @{Name='Free(GB)'; Expression={[math]::Round($_.Free/1GB, 2)}}, @{Name='Used(GB)'; Expression={[math]::Round($_.Used/1GB, 2)}}
        $lastUpdate = Get-HotFix | Sort-Object -Property InstalledOn -Descending | Select-Object -First 1

        Write-Host "`nCPU Usage: $([math]::Round($cpuUsage, 2))%"
        Write-Host "Total Memory: $([math]::Round($memory.TotalVisibleMemorySize/1MB, 2)) GB"
        Write-Host "Free Memory: $([math]::Round($memory.FreePhysicalMemory/1MB, 2)) GB"
        Write-Host "Disk Space:" -ForegroundColor Yellow
        $diskSpace | Format-Table -AutoSize
        Write-Host "Last Windows Update Installed On: $($lastUpdate.InstalledOn)"
        Log-Action "Performed system health check."
    } catch {
        Write-Host "Error: Unable to perform health check." -ForegroundColor Red
    }
}

# Helpful Tools Section
function Helpful-Tools {
    Write-Host "`nHelpful Tools:"
    Write-Host "1. Ping a Device                - Test network connectivity."
    Write-Host "2. Check IP Configuration       - View network settings (ipconfig)."
    Write-Host "3. Query DNS (nslookup)         - Check DNS resolution."
    Write-Host "4. Trace Network Route          - Use tracert to check routing."
    Write-Host "5. Return to Main Menu"
    
    $choice = Read-Host "Select a tool (1-5) or press ESC to return"
    if ($choice -eq '') { return }
    switch ($choice) {
        1 { 
            $host = Read-Host "Enter the hostname or IP to ping"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c ping $host" -NoNewWindow -Wait
        }
        2 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c ipconfig" -NoNewWindow -Wait }
        3 { 
            $domain = Read-Host "Enter the domain to query (nslookup)"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c nslookup $domain" -NoNewWindow -Wait
        }
        4 { 
            $host = Read-Host "Enter the hostname or IP to trace (tracert)"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c tracert $host" -NoNewWindow -Wait
        }
        5 { return }
        default { Write-Host "Invalid choice. Returning to menu." }
    }
}

# Main Execution Loop
while ($true) {
    $choice = Show-Menu

    if ($choice -eq "ESC" -or $choice -eq "10") {
        Write-Host "Exiting the script. Goodbye!"
        Log-Action "Exited the script."
        break
    }

    switch ($choice) {
        1 { Show-CurrentPowerPlan }
        2 { List-AllPowerPlans }
        3 { Change-PowerPlan }
        4 { Show-ComputerUptime }
        5 { Start-Process "cmd.exe" -ArgumentList "/c gpupdate /force" -NoNewWindow -Wait; Log-Action "Forced group policy update." }
        6 { Start-Process "cmd.exe" -ArgumentList "/c dsregcmd /refreshprt" -NoNewWindow -Wait; Log-Action "Triggered Intune sync." }
        7 { Start-Process "cmd.exe" -ArgumentList "/c dsregcmd /status" -NoNewWindow -Wait; Log-Action "Checked domain/work status." }
        8 { System-HealthCheck }
        9 { Helpful-Tools }
        default { Write-Host "Invalid selection. Please choose a valid option from the menu." }
    }
}
