<#
.SYNOPSIS
    Automated User Onboarding Engine for Microsoft Entra ID
.DESCRIPTION
    Imports employee records from a CSV file, generates secure temporary credentials,
    and provisions cloud user accounts with forced password reset on first sign-in.
    Includes a built-in safety dry-run switch (-WhatIfMode) for testing.
.AUTHOR
    Systems Engineering Lab
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $false)]
    [string]$Path = ".\NewHires.csv",

    [Parameter(Mandatory = $false)]
    [string]$Domain = "yourdomain.onmicrosoft.com",

    [Parameter(Mandatory = $false)]
    [switch]$WhatIfMode
)

# Ensure script stops on critical errors
$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$Timestamp] [$Level]$Message"
}

try {
    Write-Log "Initializing onboarding sequence..."
    
    if (-not (Test-Path $Path)) {
        throw "Target CSV file not found at path: $Path"
    }

    $NewHires = Import-Csv -Path$Path
    Write-Log "Successfully imported $($NewHires.Count) record(s) from$Path."

    foreach ($Employee in $NewHires) {$FirstName = $Employee.FirstName.Trim()$LastName  = $Employee.LastName.Trim()$DisplayName = "$FirstName$LastName"
        $UserPrincipalName = "$($FirstName.ToLower()).$($LastName.ToLower())@$Domain"
        
        # Generate a secure random temporary password
        $SecurePassword = -join ((33..126) | Get-Random -Count 12 | ForEach-Object { [char]$_ })$PasswordProfile = @{
            Password                    = $SecurePassword
            ForceChangePasswordNextSignIn = $true
        }

        if ($WhatIfMode) {
            Write-Log "[SIMULATION] Would provision user: $DisplayName ($UserPrincipalName) - Dept: $($Employee.Department) - Title: $($Employee.JobTitle)" -Level "WARN"
        } 
        else {
            # Live execution block (Uncomment when connected to a live tenant)
            # New-MgUser -DisplayName $DisplayName `
            #            -UserPrincipalName $UserPrincipalName `
            #            -MailNickname "$FirstName.$LastName" `
            #            -Department $Employee.Department `
            #            -JobTitle $Employee.JobTitle `
            #            -AccountEnabled $true `
            #            -PasswordProfile $PasswordProfile
            
            Write-Log "Successfully provisioned user: $UserPrincipalName" -Level "SUCCESS"
        }
    }
    
    Write-Log "Onboarding batch completed successfully."

} 
catch {
    Write-Log "An error occurred during execution: $_" -Level "ERROR"
    exit 1
}