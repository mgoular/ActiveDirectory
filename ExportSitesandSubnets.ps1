#Script Name:   Export Specific Sites and Subnets to CSV                                                                          #
#Script Author: Michael Goulart - Nike 2019                                                                                       #
################################################################################################################################  #
#Script Usage: ExportSitesandSubnets -siteNames "Retail" for single site , seperated "Retail,Retail-USA" -CSVOut C:\temp\site.csv #
#              for multiple.                                                                                                      #
###################################################################################################################################
 
#Params
Param
(
[parameter(mandatory=$true,HelpMessage="Please, provide Site Name(s). To list more than one site seprate with , e.g. Retail,Retail-USA ")][ValidateNotNullOrEmpty()][String[]]$siteNames,
[parameter(mandatory=$true,HelpMessage="Please, provide a location to save the Exported CSV with the filename. e.g C:\Temp\SCCMOGSites.CSV")][ValidateNotNullOrEmpty()][String]$CSVOut
)
 
 
#If entery is input run script
If ($siteNames -ne $null){
 
#Set Lists
[System.Collections.ArrayList]$sites = @()
[System.Collections.ArrayList]$sitesubnets = @()
 
#Get each site list in sitenames variable and add to variable
for ($i=0; $i -lt $siteNames.Count; $i++){
    $sites += [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites | Where-Object -Property Name -like $siteNames[$i]
    }
 
#Loop through each site and create simple match 
foreach ($site in $sites){
	foreach ($subnet in $site.subnets){
	   $temp = New-Object PSCustomObject -Property @{
	   'Name' = $site.Name
	   'Subnet' = $subnet; }
	    $sitesubnets += $temp
	}
}
#Export to CSV
$sitesubnets | Export-Csv $CSVOut -Force
}
#If params are not specified then inform.
Else{
    Write-host 'Script Param must be used : "ExportSitesandSubnets -siteNames Retail" for single site or , seperated "Retail,Retail-USA" for multiple followed by -CSVOut C:\temp\site.csv' -ForegroundColor Yellow
    }
#########################################################################################################