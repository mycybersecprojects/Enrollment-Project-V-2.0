# Attribution and Version
$createdDate = Get-Date "2025-01-12"  # Replace this with the creation date of your script
$lastModified = "2025-01-12"          # Update this when you modify the script
$today = Get-Date                     # Get the current date
$elapsedTime = (New-TimeSpan -Start $createdDate -End $today).Days

Write-Host "=========================="
Write-Host "Enrollment Project"
Write-Host "Created by: Erkam Koca"
Write-Host "Version: 1.0.1 (Bug Fixes)"
Write-Host "Last Modified: $lastModified"
Write-Host "Today's Date: $($today.ToString('yyyy-MM-dd'))"
Write-Host "This script has been running for $elapsedTime days since its creation."
Write-Host "=========================="

# Function: Show how long the computer has been awake
function Show-ComputerUptime {
    try {
        # Retrieve the last boot time
        $lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        $uptime = New-TimeSpan -Start $lastBootTime -End (Get-Date)

        # Display the results
        $result = "The computer has been awake for: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes, and $($uptime.Seconds) seconds."
        Write-Host $result

        # Option to copy to clipboard
        $copyChoice = Read-Host "Press 'C' to copy the result to clipboard or any key to continue"
        if ($copyChoice -ieq 'C') {
            $result | Set-Clipboard
            Write-Host "Result copied to clipboard."
        }
    } catch {
        Write-Host "Error: Unable to retrieve system uptime." -ForegroundColor Red
    }
}

# Function: Display main menu
function Show-Menu {
    Write-Host "`nChoose an option:"
    Write-Host "Power Settings:"
    Write-Host "1. Show Current Power Plan       - Displays the active power plan."
    Write-Host "2. List All Power Plans          - Lists all available power plans."
    Write-Host "3. Change Power Plan             - Switch to another power plan."
    Write-Host "Diagnostics and Troubleshooting:"
    Write-Host "4. Check Secure Boot Status      - Verifies if Secure Boot is enabled."
    Write-Host "5. Force Group Policy Update     - Runs gpupdate /force."
    Write-Host "6. Trigger Intune Sync           - Initiates a sync with Intune."
    Write-Host "7. Check Work/Domain Status      - Checks the system's domain or work account status."
    Write-Host "8. Show System Information       - Opens msinfo32 for system details."
    Write-Host "9. Network Diagnostics           - Access network troubleshooting commands."
    Write-Host "10. Helpful Tools                - Access useful CMD commands for troubleshooting."
    Write-Host "11. Special Projects             - Access additional tools and diagnostics."
    Write-Host "12. Exit                         - Closes the script."
    $choice = Read-Host "Enter your choice (1-12) or press ESC to return"
    if ($choice -eq '') { return "ESC" }
    return $choice
}

# Function: Show the current power plan
function Show-CurrentPowerPlan {
    try {
        $currentPlan = powercfg /GETACTIVESCHEME
        Write-Host "Current Power Plan:"
        Write-Host $currentPlan

        # Option to copy to clipboard
        $copyChoice = Read-Host "Press 'C' to copy the result to clipboard or any key to continue"
        if ($copyChoice -ieq 'C') {
            $currentPlan | Set-Clipboard
            Write-Host "Result copied to clipboard."
        }
    } catch {
        Write-Host "Error: Unable to retrieve the current power plan." -ForegroundColor Red
    }
}

# Function: List all power plans
function List-AllPowerPlans {
    try {
        $plans = powercfg /L
        Write-Host "Available Power Plans:"
        Write-Host $plans

        # Option to copy to clipboard
        $copyChoice = Read-Host "Press 'C' to copy the result to clipboard or any key to continue"
        if ($copyChoice -ieq 'C') {
            $plans | Set-Clipboard
            Write-Host "Result copied to clipboard."
        }
    } catch {
        Write-Host "Error: Unable to list power plans." -ForegroundColor Red
    }
}

# Function: Change the active power plan
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
            $result = "Power plan changed to: $($selectedPlan.Name)"
            Write-Host $result

            # Option to copy to clipboard
            $copyChoice = Read-Host "Press 'C' to copy the result to clipboard or any key to continue"
            if ($copyChoice -ieq 'C') {
                $result | Set-Clipboard
                Write-Host "Result copied to clipboard."
            }
        } else {
            Write-Host "Invalid selection. Returning to menu."
        }
    } catch {
        Write-Host "Error: Unable to change the power plan." -ForegroundColor Red
    }
}

# Function: Network Diagnostics
function Network-Diagnostics {
    Write-Host "Network Diagnostics Menu:"
    Write-Host "1. Ping a Device                - Test network connectivity."
    Write-Host "2. Trace Network Route          - Trace route to a host."
    Write-Host "3. DNS Query                    - Resolve domain names (nslookup)."
    Write-Host "4. Return to Main Menu"
    
    $netChoice = Read-Host "Enter your choice (1-4)"
    switch ($netChoice) {
        1 {
            $target = Read-Host "Enter the hostname or IP to ping"
            Write-Host "Pinging $target..."
            ping $target | Out-Host
        }
        2 {
            $target = Read-Host "Enter the hostname or IP to trace"
            Write-Host "Tracing route to $target..."
            tracert $target | Out-Host
        }
        3 {
            $target = Read-Host "Enter the domain name to resolve"
            Write-Host "Querying DNS for $target..."
            nslookup $target | Out-Host
        }
        4 { return }
        default { Write-Host "Invalid selection. Returning to menu." }
    }
}

# Function: Helpful Tools
function Helpful-Tools {
    Write-Host "Helpful Tools:"
    Write-Host "1. Generate Detailed GP Report     - Runs gpresult /V."
    Write-Host "2. View User Groups                - Runs whoami /groups."
    Write-Host "3. Display System Information      - Runs systeminfo."
    Write-Host "4. Device Registration Status      - Runs dsregcmd /status."
    Write-Host "5. View ARP Table                  - Runs arp -a."
    Write-Host "6. Generate Summary GP Report      - Runs gpresult /r."
    Write-Host "7. Return to Main Menu."
    
    $choice = Read-Host "Select a tool (1-7)"
    switch ($choice) {
        1 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c gpresult /V" -NoNewWindow -Wait }
        2 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c whoami /groups" -NoNewWindow -Wait }
        3 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c systeminfo" -NoNewWindow -Wait }
        4 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c dsregcmd /status" -NoNewWindow -Wait }
        5 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c arp -a" -NoNewWindow -Wait }
        6 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c gpresult /r" -NoNewWindow -Wait }
        7 { return }
        default { Write-Host "Invalid choice. Returning to menu." }
    }
}

# Main Script Execution
do {
    $choice = Show-Menu

    switch ($choice) {
        1 { Show-CurrentPowerPlan }
        2 { List-AllPowerPlans }
        3 { Change-PowerPlan }
        4 { Write-Host "Secure Boot Status check is not implemented in this version." }
        5 { Write-Host "Forcing Group Policy Update..."; Start-Process -FilePath "cmd.exe" -ArgumentList "/c gpupdate /force" -NoNewWindow -Wait }
        6 { Write-Host "Triggering Intune Sync..."; Start-Process -FilePath "cmd.exe" -ArgumentList "/c dsregcmd /refreshprt" -NoNewWindow -Wait }
        7 { Write-Host "Work/Domain Status check not implemented." }
        8 { Start-Process "msinfo32" }
        9 { Network-Diagnostics }
        10 { Helpful-Tools }
        11 { Write-Host "Special projects not implemented in this version." }
        12 { Write-Host "Exiting the script. Goodbye!"; break }
        default { Write-Host "Invalid choice. Please try again." }
    }

    Write-Host ""
} while ($choice -ne 12)
