# ==========================================
# Project: Automated Cloud User Onboarding
# Author: Systems Engineering Portfolio
# ==========================================

# 1. Connect to Microsoft Entra ID with required permissions
# (This will prompt a secure browser pop-up to log into your Azure/M365 tenant)
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.ReadWrite.All"

# 2. Define the path to your CSV file
$CsvPath = "$PSScriptRoot\NewHires.csv"

# 3. Import the CSV data
$NewHires = Import-Csv -Path $CsvPath

foreach ($User in $NewHires) {
    $UserPrincipalName = "$($User.FirstName).$($User.LastName)@yourdomain.onmicrosoft.com"
    $DisplayName = "$($User.FirstName) $($User.LastName)"
    $TempPassword = "P@ssw0rd$(Get-Random -Minimum 1000 -Maximum 9999)"

    Write-Host "Processing onboarding for: $DisplayName ($($User.JobTitle))..." -ForegroundColor Cyan

    # Define the parameters for the new cloud user
    $Params = @{
        BodyParameter = @{
            accountEnabled      = $true
            displayName         = $DisplayName
            mailNickname        = "$($User.FirstName).$($User.LastName)"
            userPrincipalName   = $UserPrincipalName
            jobTitle            = $User.JobTitle
            department          = $User.Department
            usageLocation       = "GB"
            passwordProfile     = @{
                forceChangePasswordNextSignIn = $true
                password                      = $TempPassword
            }
        }
    }

    try {
        # Uncomment the line below once you are connected to a live tenant to execute creation:
        # New-MgUser @Params
        
        Write-Host "[SUCCESS] Simulated creation for $UserPrincipalName | Temp Pass: $TempPassword" -ForegroundColor Green
    }
    catch {
        Write-Host "[ERROR] Failed to create $UserPrincipalName : $_" -ForegroundColor Red
    }
} 