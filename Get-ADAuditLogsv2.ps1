function Get-ADAuditLogsv2 {


    ## PowerShell AD Audit Alerts
    ## Charles Chukwudozie         
<# 
.SYNOPSIS
   Function to report on specific event ids.
.DESCRIPTION
  Function to report on specific event ids: User account created 4720,user removed from security enabled group 4729
  Security enabled AD group was created 4727, user was added to AD security enabled group 4728
  User account was deleted 4726. It is setup to run with a schedule.
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
    Param (
        $From = "adaudits@democonsults.com",  
        $Smtpserver = "10.0.0.14",
        $To = "infrastructure@democonsults.com", 
        $Servers = ("DC00", "DC01"),
        $Eventids = @(4720, 4729, 4727, 4728, 4726),
        $Date = ((Get-Date).AddMinutes(-60))
      
    )
    $ErrorActionPreference = 'silentlycontinue'
    foreach ($server in $servers) {
        foreach ($eventid in $eventids) {

            $events = Get-WinEvent -FilterHashtable @{logname = 'security'; id = $eventid; StartTime = $date} -ComputerName $server
            if ($events -ne $null) {
                foreach ($event in $events) {
                    $eventmessage = $event.message.split("`n")[0..16]
                    $eventsubject = $event.message.split("`n")[0]
                    $eventsubject = $eventsubject.replace("`n", "")
                    $eventsubject = $eventsubject.replace("`r", "")
                    $timecreated = $event.timecreated
                    $body = @($timecreated, $eventmessage )| Out-String
                    $subject = "Event ID" + " " + $eventid + " " + $eventsubject
                    Send-MailMessage -Body $body -From $from -SmtpServer $smtpserver -Subject $subject  -To $to
                }
            }

        }

    }
    Get-Date | Out-File c:\errorlog.txt -Append -Force 
    $Error | Out-File c:\errorlog.txt -Append -Force
}
Get-ADAuditLogsv2