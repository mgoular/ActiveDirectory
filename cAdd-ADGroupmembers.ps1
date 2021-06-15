#Script Name:   Add Group names as function                                                                          #
#Script Author: Michael Goulart - Nike 2019                                                                          #
######################################################################################################################
#Script Usage: PS C:\> cAdd-ADGroupMembers -groupname test-group001 -members test001,test0500                        #                                                                            #
######################################################################################################################

function cAdd-ADGroupMembers($groupname, [STRING[]]$members)
{
	#load the assembly (will not throw any error if already loaded)
	$am = Add-Type -AssemblyName System.DirectoryServices.AccountManagement
	
	#create the PrincipalContext object
	$pc = [System.DirectoryServices.AccountManagement.PrincipalContext]::new([System.DirectoryServices.AccountManagement.ContextType]::`Domain)
	
	#Set the identifier type to "SamAccountName"
	$IDType = [System.DirectoryServices.AccountManagement.IdentityType]::SamAccountName
	
	#find and load the group from AD
	$group = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($pc, $groupname)
	#Check if group exists
	if ($group -eq $null)
	{
		Write-Error "Group was not found in Active Directory" -Category ObjectNotFound -ErrorId "System.DirectoryServices.AccountManagement.ObjectNotFound"
		Return
	}
	
	#add each specified member to the group object
	foreach ($member in $members)
	{
		#Check if object is already a member of the group
		if (($group.Members.Contains($pc, $IDType, $member)))
		{
			Write-Warning "Object ""$member"" is already a member of this group"
		}
		Else
		{
			#add the new member
			try
                        {
                          $group.Members.Add($pc, $IDType, $member)
                          Write-Host "Added $member"
                        }
                        catch
                        {
                          write-error "Could not add object ""$member"".`n $($_.exception.message)" -ErrorId $_.FullyQualifiedErrorId     
                        }
		}
	}
	#save the group
	$group.Save()
	#clean up
	$group.Dispose()
	$pc.Dispose()
	Return "Done"
}