# Attribution and Version
$createdDate = Get-Date "2025-01-12"  # Replace this with the creation date of your script
$lastModified = "2025-01-12"          # Update this when you modify the script
$today = Get-Date                     # Get the current date
$elapsedTime = (New-TimeSpan -Start $createdDate -End $today).Days

Write-Host "=========================="
Write-Host "Enrollment Project"
Write-Host "Created by: Erkam Koca"
Write-Host "Version: 1.2.0 (Updated)"
Write-Host "Last Modified: $lastModified"
Write-Host "Today's Date: $($today.ToString('yyyy-MM-dd'))"
Write-Host "This script has been running for $elapsedTime days since its creation."
Write-Host "=========================="

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
# Attribution and Version
$createdDate = Get-Date "2025-01-12"  # Replace this with the creation date of your script
$lastModified = "2025-01-12"          # Update this when you modify the script
$today = Get-Date                     # Get the current date
$elapsedTime = (New-TimeSpan -Start $createdDate -End $today).Days

Write-Host "=========================="
Write-Host "Enrollment Project"
Write-Host "Created by: Erkam Koca"
Write-Host "Version: 1.2.0 (Updated)"
Write-Host "Last Modified: $lastModified"
Write-Host "Today's Date: $($today.ToString('yyyy-MM-dd'))"
Write-Host "This script has been running for $elapsedTime days since its creation."
Write-Host "=========================="

# Display system uptime
Show-ComputerUptime
}
# Function: Power Options Submenu
function Show-PowerOptionsMenu {
    Write-Host "`nPower Options:"
    Write-Host "1. Show Current Power Plan       - Displays the active power plan."
    Write-Host "2. List All Power Plans          - Lists all available power plans."
    Write-Host "3. Change Power Plan             - Switch to another power plan."
    Write-Host "4. Return to Main Menu"

    $choice = Read-Host "Enter your choice (1-4)"
    switch ($choice) {
        1 { Show-CurrentPowerPlan }
        2 { List-AllPowerPlans }
        3 { Change-PowerPlan }
        4 { Write-Host "Returning to Main Menu..."; return }
        default { Write-Host "Invalid choice. Please try again."; Show-PowerOptionsMenu }
    }
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

# Function: Show how long the computer has been awake
function Show-ComputerUptime {
    try {
        $lastBootTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
        $uptime = New-TimeSpan -Start $lastBootTime -End (Get-Date)

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

# Function: Force a group policy update
function Force-GPUpdate {
    try {
        Write-Host "Forcing group policy update..."
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c gpupdate /force" -NoNewWindow -Wait
        Write-Host "Group policy update completed."
    } catch {
        Write-Host "Error: Unable to force group policy update." -ForegroundColor Red
    }
}

# Function: Trigger Intune Sync
function Trigger-IntuneSync {
    try {
        Write-Host "Triggering Intune Sync..."
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c dsregcmd /refreshprt" -NoNewWindow -Wait
        Write-Host "Intune sync triggered."
    } catch {
        Write-Host "Error: Unable to trigger Intune sync." -ForegroundColor Red
    }
}

# Function: Helpful Tools
function Helpful-Tools {
    Write-Host "Helpful Tools:"
    Write-Host "1. Ping a Device                - Test network connectivity."
    Write-Host "2. Check IP Configuration       - View network settings (ipconfig)."
    Write-Host "3. Query DNS (nslookup)         - Check DNS resolution."
    Write-Host "4. Trace Network Route          - Use tracert to check routing."
    Write-Host "5. Return to Main Menu"

    $choice = Read-Host "Select a tool (1-5)"
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

# Function: Display main menu
function Show-Menu {
    Write-Host "`nChoose an option:"
    Write-Host "1. Power Options                - Manage and view power plans."
    Write-Host "2. Show Computer Uptime         - Displays the local system's uptime."
    Write-Host "3. Force Group Policy Update    - Runs gpupdate /force."
    Write-Host "4. Trigger Intune Sync          - Initiates a sync with Intune."
    Write-Host "5. Helpful Tools                - Access useful CMD commands for troubleshooting."
    Write-Host "6. Exit                         - Closes the script."

    $choice = Read-Host "Enter your choice (1-6)"
    if ($choice -eq '') { return "ESC" }
    return $choice
}

# Main Execution Loop
do {
    $choice = Show-Menu

    switch ($choice) {
        1 { Show-PowerOptionsMenu }  # Consolidated power options menu
        2 { Show-ComputerUptime }
        3 { Force-GPUpdate }
        4 { Trigger-IntuneSync }
        5 { Helpful-Tools }
        6 { Write-Host "Exiting the script. Goodbye!"; break }
        default { Write-Host "Invalid choice. Please try again." }
    }

    Write-Host ""
} while ($choice -ne 6)
