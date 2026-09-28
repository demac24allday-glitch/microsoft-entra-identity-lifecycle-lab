# Microsoft Entra ID - Joiner, Mover, Leaver Lab
# Demonstrates identity lifecycle automation using Microsoft Graph PowerShell.
# Intended for demonstration in a test tenant.
# Replace placeholder tenant and password values before execution.

# Connect to Microsoft Graph
Connect-MgGraph -Scopes `
    "User.ReadWrite.All",
    "Group.ReadWrite.All",
    "Directory.ReadWrite.All"

# =========================================
# JOINER
# =========================================

$PasswordProfile = @{
    Password = "REPLACE-WITH-TEMP-PASSWORD"
    ForceChangePasswordNextSignIn = $true
}

$NewUser = New-MgUser `
    -AccountEnabled `
    -DisplayName "Daniel Kim" `
    -MailNickname "daniel.kim" `
    -UserPrincipalName "daniel.kim@YOURTENANT.onmicrosoft.com" `
    -PasswordProfile $PasswordProfile `
    -Department "Finance" `
    -JobTitle "Junior Financial Analyst"

$FinanceGroup = Get-MgGroup -Filter "displayName eq 'SG-Finance'"

$params = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($NewUser.Id)"
}

New-MgGroupMemberByRef `
    -GroupId $FinanceGroup.Id `
    -BodyParameter $params

Write-Host "JOINER COMPLETE: Daniel Kim created and added to SG-Finance."


# =========================================
# MOVER
# =========================================

$Ethan = Get-MgUser -Filter "displayName eq 'Ethan Cole'"

Update-MgUser `
    -UserId $Ethan.Id `
    -Department "Finance" `
    -JobTitle "Financial Services Representative"

$SalesGroup = Get-MgGroup -Filter "displayName eq 'SG-Sales'"
$FinanceGroup = Get-MgGroup -Filter "displayName eq 'SG-Finance'"

Remove-MgGroupMemberByRef `
    -GroupId $SalesGroup.Id `
    -DirectoryObjectId $Ethan.Id

$params = @{
    "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($Ethan.Id)"
}

New-MgGroupMemberByRef `
    -GroupId $FinanceGroup.Id `
    -BodyParameter $params

Write-Host "MOVER COMPLETE: Ethan Cole moved from SG-Sales to SG-Finance."


# =========================================
# LEAVER
# =========================================

$Ava = Get-MgUser -Filter "displayName eq 'Ava Carter'"

Update-MgUser `
    -UserId $Ava.Id `
    -AccountEnabled:$false

Revoke-MgUserSignInSession `
    -UserId $Ava.Id

$FinanceGroup = Get-MgGroup -Filter "displayName eq 'SG-Finance'"

Remove-MgGroupMemberByRef `
    -GroupId $FinanceGroup.Id `
    -DirectoryObjectId $Ava.Id

Write-Host "LEAVER COMPLETE: Ava Carter disabled, sessions revoked, and removed from SG-Finance."
