function New-EmployeeUserAccount {

<# 
.SYNOPSIS
    Interactive Function Automates Active Directory User and Mailbox Creation.
.DESCRIPTION
    Interactive Function Automates Active Directory User and Mailbox Creation.
.PARAMETER Eventids
    Array of event ids to be audited and reported on.
.PARAMETER Smtpserver
    Smtp Server for processing email.
.PARAMETER From
    From email address.
.PARAMETER To
    To email address.
.EXAMPLE
    Get-ADAuditLogsv2
       
.FUNCTIONALITY
    PowerShell Language
/#>

    [CmdletBinding()]
    Param (
        $adforest = ((Get-ADDomain).forest | Out-String),
        [Parameter(Mandatory = $True, Position = 0)][ValidateNotNullOrEmpty()][string]$GivenName,
        [string]$firstName1 = $GivenName.trim(" ", ".", ","),
        [string]$firstname = (Get-Culture).TextInfo.ToTitleCase($firstname1),
        [Parameter(Mandatory = $True)] [ValidateNotNullOrEmpty()][string]$Surname,
        [string]$lastname1 = $Surname.trim(" ", ".", ","),
        [string]$lastname = (Get-Culture).TextInfo.ToTitleCase($lastname1),
        $path = ("\\labtarget\Scripts\Departments.txt"),
        $userPrincipalName = "$firstname" + "$lastname" + "@" + $adforest,
        $name = "$firstName" + " " + "$lastName",
        $sam = "$firstname" + "$lastname",
        $alias = "$firstname" + "$lastname",
        $initialpassword = 'test1234',
        $FromEmailAddress = "alerts@labnet.net",
        $ToEmailAddress = "infrastructure@labnet.net",
        $smtpserver = "exch00.labnet.net",
        $connectionuri = "http://exch00/powershell"
    )
    $path = ("\\labtarget\Scripts\Departmentsdropdown.txt")
    $departmentlist = Get-Content -Path $path
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    $objForm = New-Object System.Windows.Forms.Form
    $objForm.Text = "Select a Department"
    $objForm.Size = New-Object System.Drawing.Size(300, 200)
    $objForm.StartPosition = "CenterScreen"
    $objForm.KeyPreview = $True
    $objForm.Add_KeyDown( {if ($_.KeyCode -eq "Enter")
            {$x = $objListBox.SelectedItem; $objForm.Close()}})
    $objForm.Add_KeyDown( {if ($_.KeyCode -eq "Escape")
            {$objForm.Close()}})
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75, 120)
    $OKButton.Size = New-Object System.Drawing.Size(75, 23)
    $OKButton.Text = "OK"
    $OKButton.Add_Click( {$objListBox.SelectedItem; $objForm.Close()})
    $objForm.Controls.Add($OKButton)
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150, 120)
    $CancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click( {$objForm.Close()})
    $objForm.Controls.Add($CancelButton)
    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10, 20)
    $objLabel.Size = New-Object System.Drawing.Size(280, 20)
    $objLabel.Text = "Please select a department:"
    $objForm.Controls.Add($objLabel)
    $objListBox = New-Object System.Windows.Forms.ListBox
    $objListBox.Location = New-Object System.Drawing.Size(10, 40)
    $objListBox.Size = New-Object System.Drawing.Size(260, 20)
    $objListBox.Height = 80
    forEach ($department in $departmentlist) {
        [void]$objListBox.Items.Add($department)
    }
    $objForm.Controls.Add($objListBox)
    $objForm.Topmost = $True
    $objForm.Add_Shown( {$objForm.Activate()})
    [void] $objForm.ShowDialog()
    $department1 = $objListBox.SelectedItem.ToString()
    $department = $department1.trim()
    $department = $department.replace("`n", "")
    $department = $department.replace("`r", "")
    $initialgroups = 'OfficeUsers', 'HeadOffice'
    $aduser = Get-ADUser -Filter "Name -like '*$name*'"
    $whoami = whoami /upn
    try {
        if ( $aduser -eq $null) {
            Switch ( $department) {
                HR {
                    $OU = "OU=HR_OU,OU=Users-all,DC=labnet,dc=net"
                    $hrgroups = 'HRStaff'
                    New-ADUser -AccountPassword (convertto-securestring $initialpassword -asplaintext -force) -GivenName $firstname -SurName $lastname -UserPrincipalName $userprincipalname -Name $name -Enabled $true -Path $OU -Department $department -SamAccountName $Sam -ChangePasswordAtLogon $true
                    Add-ADPrincipalGroupMembership -Identity $sam -MemberOf $hrgroups
                }
                IT {
                    $OU = "OU=IT_OU,OU=Users-all,DC=labnet,dc=net"
                    $itgroups = 'ITStaff'
                    New-ADUser -AccountPassword (convertto-securestring $initialpassword -asplaintext -force) -GivenName $firstname -SurName $lastname -UserPrincipalName $userprincipalname -Name $name -Enabled $true -Path $OU -Department $department -SamAccountName $Sam -ChangePasswordAtLogon $true
                    Add-ADPrincipalGroupMembership -Identity $sam -MemberOf $itgroups
                }
                Marketing {
                    $OU = "OU=Marketing_OU,OU=Users-all,DC=labnet,dc=net"
                    $marketinggroups = 'MarketingStaff'
                    New-ADUser -AccountPassword (convertto-securestring $initialpassword -asplaintext -force) -GivenName $firstname -SurName $lastname -UserPrincipalName $userprincipalname -Name $name -Enabled $true -Path $OU -Department $department -SamAccountName $Sam -ChangePasswordAtLogon $true
                    Add-ADPrincipalGroupMembership -Identity $sam -MemberOf $marketinggroups
                }
                Production {
                    $OU = "OU=Production_OU,OU=Users-all,DC=labnet,dc=net"
                    $productiongroups = 'ProductionStaff'
                    New-ADUser -AccountPassword (convertto-securestring $initialpassword -asplaintext -force) -GivenName $firstname -SurName $lastname -UserPrincipalName $userprincipalname -Name $name -Enabled $true -Path $OU -Department $department -SamAccountName $Sam -ChangePasswordAtLogon $true
                    Add-ADPrincipalGroupMembership -Identity $sam -MemberOf $productiongroups
                }
                Accounting {
                    $OU = "OU=Accounting_OU,OU=Users-all,DC=labnet,dc=net"
                    $accountinggroups = 'AccountingStaff'
                    New-ADUser -AccountPassword (convertto-securestring $initialpassword -asplaintext -force) -GivenName $firstname -SurName $lastname -UserPrincipalName $userprincipalname -Name $name -Enabled $true -Path $OU -Department $department -SamAccountName $Sam -ChangePasswordAtLogon $true
                }
                Default {
                    #$department = $null
                    $OU = "CN=Users,DC=labnet,DC=net"
                    New-ADUser -AccountPassword (convertto-securestring $initialpassword -asplaintext -force) -GivenName $firstname -SurName $lastname -UserPrincipalName $userprincipalname -Name $name -Enabled $true -Path $OU -Department $department -SamAccountName $Sam -ChangePasswordAtLogon $true
                }
            }
            Add-ADPrincipalGroupMembership -Identity $sam -MemberOf $initialgroups
            Write-Host -Object " Active Directory user $name has been created. Please wait while we enable a mailbox for this user. Thank you."
            while ( $a -ne 5) {
                if ($aduser -eq $null) {
                    $a++
                }
            }
            $s = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $connectionuri
            Import-PSSession -Session $s -AllowClobber | Out-Null
            Enable-Mailbox -identity $name -Alias $alias | Out-Null
            Send-MailMessage -From $FromEmailAddress -to $ToEmailAddress -Subject "New User Created Notification" -Body " New User $name and mailbox have been created in the $OU Organizational Unit by $whoami. !!" -SmtpServer $smtpserver
            Write-Host "Active Directory User $name and their Mailbox have been created successfully in the $OU Organizational Unit by $whoami. !!"
            Remove-PSSession -Session $s
        }
        else {
            Write-Host -Object "The user $name already exists !!"
        }
    }
    catch {
        Get-Date | Out-File \\labtarget\Scripts\errorlog.txt -Append -Force
        $_ | Out-File \\labtarget\Scripts\errorlog.txt -Append
        Write-Host -Object "Please check the Logs for errors."
    }
}
New-EmployeeUserAccount

PS: It might be necessary to assign “Send-As” permission to the help desk support users to enable them run the Send-MailMessage cmdlet using a different ‘from’ address :
Add-ADPermission -Identity "CN=Alerts,OU=IT_OU,OU=Users-All,DC=LabNet,DC=net" -ExtendedRights Send-As -User kriskay