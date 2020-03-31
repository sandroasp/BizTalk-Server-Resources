[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")

################################################################## 
# Function to Enable or Disable a SQL Server Network Protocol
##################################################################
function ChangeSQLProtocolStatus($server,$instance,$protocol,$enable){

	$smo = 'Microsoft.SqlServer.Management.Smo.'
	
	$wmi = new-object ($smo + 'Wmi.ManagedComputer')

	$singleWmi = $wmi | where {$_.Name -eq $server}  

	$uri = "ManagedComputer[@Name='$server']/ServerInstance[@Name='$instance']/ServerProtocol[@Name='$protocol']"
	
	$protocol = $singleWmi.GetSmoObject($uri)
	
	$protocol.IsEnabled = $enable
	
	$protocol.Alter()
	
	$protocol
}

################################################################## 
# Enable TCP/IP SQL Server Network Protocol
##################################################################
ChangeSQLProtocolStatus -server "BTS2010LAB01" -instance "MSSQLSERVER" -protocol "TCP" -enable $true

################################################################## 
# Enable Named Pipes SQL Server Network Protocol
##################################################################
ChangeSQLProtocolStatus -server "BTS2010LAB01" -instance "MSSQLSERVER" -protocol "NP" -enable $true

################################################################## 
# Disable Shared Memory SQL Server Network Protocol
##################################################################
ChangeSQLProtocolStatus -server "BTS2010LAB01" -instance "MSSQLSERVER" -protocol "SM" -enable $false

################################################################## 
# Disable VIA SQL Server Network Protocol
##################################################################
ChangeSQLProtocolStatus -server "BTS2010LAB01" -instance "MSSQLSERVER" -protocol "VIA" -enable $false

$service = get-service "MSSQLSERVER" 
restart-service $service.name -force #Restart SQL Services

$service = get-service "ENTSSO" #Start Enterprise Single Sign-On Service
if( $service -ne $null )
{
	start-service $service.name
}
get-service BTS* | foreach-object -process {start-service $_.Name} # Start BizTalk Services