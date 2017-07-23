Function Get-HostProperties {

    <# 
.SYNOPSIS
   This function will display total and available disk space.
.DESCRIPTION
This function will display total and available disk space, it will also show the available memory at any given time for a server within an AD domain infrastructure.
It uses the WMIObject win32_operatingsystem class to retrieve specific host properties.

.EXAMPLE
    Get-HostProperties
       
.FUNCTIONALITY
    PowerShell Language
/#>
    param ($computerName = (Read-Host "Enter Server Name")
    )
    Get-WmiObject -Class win32_logicaldisk -ComputerName $computerName | ft DeviceID, @{Name = "Free Disk Space (GB)"; e = {$_.FreeSpace / 1GB}}, @{Name = "Total Disk Size (GB)"; e = {$_.Size / 1GB}} -AutoSize
    Get-WmiObject -Class win32_computersystem -ComputerName $computerName | ft @{Name = "Physical Processors"; e = {$_.NumberofProcessors}} , @{Name = "Logical Processors"; e = {$_.NumberOfLogicalProcessors}} , @{Name = "TotalPhysicalMemory (GB)"; e = {[math]::truncate($_.TotalPhysicalMemory / 1GB)}}, Model -AutoSize
    Get-WmiObject -Class win32_operatingsystem -ComputerName $computerName | ft @{Name = "Total Visible Memory Size (GB)"; e = {[math]::truncate($_.TotalVisibleMemorySize / 1MB)}}, @{Name = "Free Physical Memory (GB)"; e = {[math]::truncate($_.FreePhysicalMemory / 1MB)}} -AutoSize
    Get-WmiObject -Class win32_operatingsystem -ComputerName $computerName | ft @{Name = "Operating System"; e = {$_.Name}} -AutoSize
    Get-WmiObject -Class win32_bios -ComputerName $computerName | ft @{Name = "ServiceTag"; e = {$_.SerialNumber}}
}
Get-HostProperties