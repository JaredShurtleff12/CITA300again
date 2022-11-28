# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv C:\Users\shurtl056\Desktop\Lab10\bulk_users2.csv


#Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	#Read user data from each field in each row and assign the data to a variable as below
		
	$Username 	= $User.username
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
	$OU 		= $User.ou #This field refers to the OU the user account is to be created in
    $email      = $User.email
    $streetaddress = $User.streetaddress
    $city       = $User.city
    $postalcode = $User.postalcode
    $state      = $User.state
    $country    = $User.country
    $telephone  = $User.telephone
    $jobtitle   = $User.jobtitle
    $company    = $User.company
    $department = $User.department
    $Password = $User.Password
    $secPw = Convertto-SecureString -String $Password -AsPlainText -Force


	#Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 #If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		#User does not exist then proceed to create the new user account
		
        #Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@shurtl056.local" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -City $city `
            -Company $company `
            -State $state `
            -PostalCode $postalcode `
            -Country $country `
            -StreetAddress $streetaddress `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword $secPw `
            # testing
            
	}
    #Account will be added to an OU called AllowInternetAccess
    Add-ADGroupMember -Identity "AllowInternetAccess" -Members $Username


    #**** Add User Share *********
    $SMBToCreate = "C:\Parent-Directory\$Username\"

    New-Item -Path $SMBToCreate -ItemType Directory

    if(!(Get-SmbShare -Name $Username -ea 0)){
        New-SmbShare -Name $Username -Path $SMBToCreate -FullAccess "shurtl056\Administrator", "shurtl056\domain admins" -ReadAccess "shurtl056\$Username"
        Write-Host "Successfully created share for $Username." -ForegroundColor Green
    }
    
    
}
