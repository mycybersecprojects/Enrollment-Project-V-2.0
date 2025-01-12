# Enrollment-Project-V-2.0

Created by: Erkam Koca
Version: 2.0.0 (Bug Fixes)
Last Modified: January 12, 2025

## Overview
The **Enrollment Project** is a comprehensive PowerShell script designed to streamline and automate the enrollment process for Windows computers. The script includes various tools and features to assist system engineers in managing devices during and after enrollment. It simplifies tasks like managing power settings, triggering group policy updates, checking system status, troubleshooting, and adding computers to Active Directory groups.

## Features
### Power Settings
1. **Show Current Power Plan**: Displays the active power plan.
2. **List All Power Plans**: Lists all available power plans on the system.
3. **Change Power Plan**: Switches to a different power plan.

### Diagnostics and Troubleshooting
4. **Check Secure Boot Status**: Verifies if Secure Boot is enabled.
5. **Force Group Policy Update**: Runs `gpupdate /force` to apply Group Policies immediately.
6. **Trigger Intune Sync**: Initiates a sync with Microsoft Intune.
7. **Check Work/Domain Status**: Displays the domain or work account configuration.
8. **Show System Information**: Opens `msinfo32` to provide detailed system data.

### Network Diagnostics
9. **Ping a Device**: Tests connectivity to a specified host or IP.
10. **Trace Network Route**: Traces the route packets take to reach a destination.
11. **DNS Query**: Resolves domain names to IP addresses using `nslookup`.

### Helpful Tools
- **Generate Detailed Group Policy Report**: Runs `gpresult /V` to generate verbose group policy data.
- **View User Groups**: Runs `whoami /groups` to display the user’s group memberships.
- **Display System Information**: Runs `systeminfo` for system details.
- **Device Registration Status**: Runs `dsregcmd /status` to verify Azure AD join status.
- **View ARP Table**: Runs `arp -a` to display the Address Resolution Protocol table.
- **Generate Summary Group Policy Report**: Runs `gpresult /r` for a concise report.
- **Set Restart Time**: Schedules a system restart at a user-defined time.

### Special Projects
- Includes custom tools and scripts tailored for specific diagnostic or administrative tasks.

### Automation and Reporting
- **System Uptime**: Displays how long the system has been running.
- **Logging**: Outputs critical actions and results to a log file for troubleshooting and auditing.
- **Active Directory Integration**: Automates adding computers to AD groups post-enrollment.

## Prerequisites
1. **Environment**:
   - Windows operating system.
   - Administrative privileges to run the script.
2. **Modules and Tools**:
   - PowerShell Active Directory module (`RSAT: Active Directory` tools must be installed).
3. **Network Configuration**:
   - Connectivity to the domain controller and necessary servers.

## How to Use
1. **Download and Prepare the Script**:
   - Save the script to a local directory.
   - Ensure execution policy allows running PowerShell scripts:
     ```powershell
     Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
     ```
2. **Run the Script**:
   - Open PowerShell as Administrator.
   - Execute the script:
     ```powershell
     .\EnrollmentProject.ps1
     ```
3. **Navigate the Menu**:
   - Follow the prompts to select options and perform desired actions.

## Customization
- The script can be customized to add or modify features, such as integrating additional diagnostic tools or adjusting group membership tasks.

## Troubleshooting
- **PowerShell Errors**:
  - Ensure all required modules are installed.
  - Verify script permissions.
- **Active Directory Issues**:
  - Confirm network connectivity to the domain controller.
  - Ensure the user account has adequate permissions to modify AD groups.

## Future Enhancements
- Integration with Intune APIs for detailed compliance reporting.
- Advanced logging and notification system (e.g., email or toast notifications).
- Scheduled task automation for periodic system checks.

## Credits
- **Author**: Erkam Koca
- **Version**: 1.0.0
- **Last Modified**: January 12, 2025

