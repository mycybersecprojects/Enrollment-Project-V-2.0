# Attribution and Version
$createdDate = Get-Date "2025-01-12"  # Replace this with the creation date of your script
$lastModified = "2025-01-12"          # Update this when you modify the script
$today = Get-Date                     # Get the current date
$elapsedTime = (New-TimeSpan -Start $createdDate -End $today).Days

Write-Host "=========================="
Write-Host "Enrollment Project"
Write-Host "Created by: Erkam Koca"
Write-Host "Version: 1.0.0"
Write-Host "Last Modified: $lastModified"
Write-Host "Today's Date: $($today.ToString('yyyy-MM-dd'))"

# Show how long the computer has been awake
function Show-ComputerUptime {
    # Retrieve the last boot time
    $lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
    $uptime = New-TimeSpan -Start $lastBootTime -End (Get-Date)

    # Display the results
    $result = "The computer has been awake for: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes, and $($uptime.Seconds) seconds."
    Write-Host $result

    # Option to copy to clipboard
    $copyChoice = Read-Host "Press 'C' to copy the result to clipboard or any key to continue"
    if ($copyChoice -eq 'C') {
        $result | Set-Clipboard
        Write-Host "Result copied to clipboard."
    }
}

Show-ComputerUptime

Write-Host "This script has been running for $elapsedTime days since its creation."
Write-Host "=========================="

# Display main menu
function Show-Menu {
    Write-Host "Choose an option:"
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
    Write-Host "10. Helpful Tools                 - Access useful CMD commands for troubleshooting."
    Write-Host "11. Special Projects             - Access additional tools and diagnostics."
    Write-Host "12. Exit                         - Closes the script."
    $choice = Read-Host "Enter your choice (1-12) or press ESC to return"
    if ($choice -eq '') { return "ESC" }
    return $choice
}

# Power Plan Functions
function Show-CurrentPowerPlan {
    $currentPlan = powercfg /GETACTIVESCHEME
    Write-Host "Current Power Plan:"
    Write-Host $currentPlan

    # Option to copy to clipboard
    $copyChoice = Read-Host "Press 'C' to copy the result to clipboard or any key to continue"
    if ($copyChoice -eq 'C') {
        $currentPlan | Set-Clipboard
        Write-Host "Result copied to clipboard."
    }
}

function List-AllPowerPlans {
    $plans = powercfg /L
    Write-Host "Available Power Plans:"
    Write-Host $plans

    # Option to copy to clipboard
    $copyChoice = Read-Host "Press 'C' to copy the result to clipboard or any key to continue"
    if ($copyChoice -eq 'C') {
        $plans | Set-Clipboard
        Write-Host "Result copied to clipboard."
    }
}

function Change-PowerPlan {
    # Get the list of power plans and parse the output
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
        if ($copyChoice -eq 'C') {
            $result | Set-Clipboard
            Write-Host "Result copied to clipboard."
        }
    } else {
        Write-Host "Invalid selection. Returning to menu."
    }
}

function Network-Diagnostics {
    Write-Host "Network Diagnostics Menu:"
    Write-Host "1. Ping a Device - Test network connectivity."
    Write-Host "2. Trace Network Route - Trace route to a host."
    Write-Host "3. DNS Query - Resolve domain names (nslookup)."
    $netChoice = Read-Host "Enter your choice (1-3) or press ESC to return"
    if ($netChoice -eq '') { return }
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
        default {
            Write-Host "Invalid selection. Returning to menu."
        }
    }
}

# Helpful Tools Section
function Helpful-Tools {
    Write-Host "Helpful Tools:"
    Write-Host "1. Generate Detailed GP Report     - Runs gpresult /V."
    Write-Host "2. View User Groups                - Runs whoami /groups."
    Write-Host "3. Display System Information      - Runs systeminfo."
    Write-Host "4. Device Registration Status      - Runs dsregcmd /status."
    Write-Host "5. View ARP Table                  - Runs arp -a."
    Write-Host "6. Generate Summary GP Report      - Runs gpresult /r."
    Write-Host "7. Set Restart Time                - Schedule a system restart."
    Write-Host "8. Return to Main Menu"
    
    $choice = Read-Host "Select a tool (1-8) or press ESC to return"
    if ($choice -eq '') { return }
    switch ($choice) {
        1 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c gpresult /V" -NoNewWindow -Wait }
        2 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c whoami /groups" -NoNewWindow -Wait }
        3 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c systeminfo" -NoNewWindow -Wait }
        4 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c dsregcmd /status" -NoNewWindow -Wait }
        5 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c arp -a" -NoNewWindow -Wait }
        6 { Start-Process -FilePath "cmd.exe" -ArgumentList "/c gpresult /r" -NoNewWindow -Wait }
        7 {
            $time = Read-Host "Enter the restart time in 24-hour format (HH:MM)"
            schtasks /create /tn "Restart" /tr "shutdown /r /f" /sc once /st $time /f
            Write-Host "Restart task scheduled at $time."
        }
        8 { return }
        default { Write-Host "Invalid choice. Returning to menu." }
    }
}

# Special Projects Section
function Run-SpecialProjects {
    Write-Host "Launching Special Projects Tools..."
    .\special_projects_tools.ps1
