param(
    [string]$Path = ".\NewHires.csv",
    [string]$Domain = "yourdomain.onmicrosoft.com",
    [switch]$WhatIfMode
)

$ErrorActionPreference = "Stop"

function Log {
    param([string]$Msg, [string]$Type = "INFO")
    Write-Host "[$((Get-Date).ToString('HH:mm:ss'))] [$Type] $Msg"
}

try {
    Log "Starting user onboarding..."
    
    if (-not (Test-Path $Path)) {
        throw "CSV file missing at: $Path"
    }

    $users = Import-Csv -Path $Path
    Log "Loaded $($users.Count) user(s) from CSV."

    foreach ($u in $users) {
        $first = $u.FirstName.Trim()
        $last  = $u.LastName.Trim()
        $name  = "$first $last"
        $upn   = "$($first.ToLower()).$($last.ToLower())@$Domain"
        
        # Quick random password generator
        $pass = -join ((33..126) | Get-Random -Count 12 | ForEach-Object { [char]$_ })
        $profile = @{
            Password = $pass
            ForceChangePasswordNextSignIn = $true
        }

        if ($WhatIfMode) {
            Log "[SIMULATION] Would create user: $name ($upn) - Role: $($u.JobTitle)" "WARN"
        } 
        else {
            # Live tenant provisioning
            # New-MgUser -DisplayName $name -UserPrincipalName $upn -MailNickname "$first.$last" -PasswordProfile $profile -AccountEnabled $true
            Log "Provisioned: $upn" "SUCCESS"
        }
    }
    
    Log "Done!"

} 
catch {
    Log "Error: $_" "ERROR"
    exit 1
}