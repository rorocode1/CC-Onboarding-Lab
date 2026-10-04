# Cloud User Onboarding Automation

A lightweight, automated user provisioning tool built with **PowerShell** and **Microsoft Graph API**, designed to streamline employee lifecycle management in Microsoft Entra ID.

## Overview
This script automates the creation of cloud user accounts from a CSV data source, assigns relevant job titles and departments, and generates secure temporary credentials with forced password resets on first sign-in.

## Features
- **CSV Data Import:** Reads new hire details dynamically.
- **Automated Parameter Mapping:** Assigns display names, user principal names, departments, and job titles.
- **Secure Credential Generation:** Automatically generates randomized temporary passwords with `forceChangePasswordNextSignIn` enabled.
- **Error Handling:** Built-in try/catch blocks for safe execution and logging.

## Prerequisites
- Windows PowerShell 5.1+ or PowerShell 7+
- `Microsoft.Graph` PowerShell module
- Microsoft Entra ID Tenant Administrator permissions

## Usage
1. Populate `NewHires.csv` with employee details.
2. Update the domain suffix in `Onboard-Users.ps1`.
3. Run the script:
   ```powershell
   .\Onboard-Users.ps1