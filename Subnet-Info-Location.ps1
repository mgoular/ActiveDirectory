$list = get-content -Path "C:\Temp\LondonCDT.txt"
Foreach ($ip in $list) { 
    #    Get-ADReplicationSubnet $ip
    #    Added new line only to get the location
    Get-ADReplicationSubnet $ip -properties * | select-object location
}
Write-Host "--------------------------------------------"
Write-Host   FULL LIST OF CONVERSE SUBNETS LOCATION
Write-Host "--------------------------------------------"

