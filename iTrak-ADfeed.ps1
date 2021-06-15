<#
.SYNOPSIS
   iTrak - Daily AD extract for all employees in EHQ 

.DESCRIPTION
   Performs an Active Directory employee extract 

.NOTES
   Written March 28th, 2019 by Michael Goulart, Nike Directory Services

.EXAMPLE
   .\iTrak-ADfeed.ps1 
   
   Extracts samaccountname,email address and cubicle location, if valid,
   and directs the output to ADEmployees+DATE.csv + Send one email with the extraction.

.INPUTS
   None - this script does not accept input

.OUTPUTS
   Text in CSV format with some strings quoted.
#>


# Define Exclusions
$Exclude = "A.SF*","da.*","p.*","S.TAS.*","s.sop.*","A.SYNC.*","A.Tab.*","sa.*","a.*","s.*","r.*","Helpdesk,*"

# Format the Query
$Users = Get-ADUser -Filter {City -eq "CITYNAME" -and enabled -eq $true} -Properties Mail,Givenname,Surname,nike-Cubelocation,EmployeeID,OfficePhone | where {$_.mail -ne $null} 

# Run the exclusions
foreach ($item in $Exclude)
{
$Users = $Users | where {$_.Name -notlike "*$item*"}
}

# Write out the CSV and Export
$Users | Select-Object Givenname,Surname,Mail,Nike-Cubelocation,EmployeeID,OfficePhone | export-csv ADEmployees_$((Get-Date).ToString('MM-dd-yyyy_hh-mm')).csv -NoTypeInformation


# Function send mail
$From = "automate@xxxxx.com"
$To = "michael.goulart@xxxxx.com"
$Subject = "iTrak Daily Feed"
$SMTPBody = "Itrak Daily feed"
$SMTPServer = "mailhost.xxxxx.com"
$SMTPPort = ""
$file_attachments = @()

$SMTPMessage = @{
    To = $To
    From = $From
	Subject = "$Subject"
    Smtpserver = $SMTPServer
}

$File = Get-ChildItem $Path | Where { ($_.LastWriteTime -ge [datetime]::Now.AddDays(-1) ) -and ( $_.BaseName -like 'ADEmployees_*') }
If ($File)
{	$SMTPBody = " The following files have recently been added/changed:  "
	$File | ForEach { $SMTPBody += "$($_.FullName)" }
	$File | ForEach {$file_attachments += $_.FullName}


	Send-MailMessage @SMTPMessage -Body $SMTPBody -Attachments $file_attachments
}
