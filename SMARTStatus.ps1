#SMARTStatus.ps1 - this script uses smartmontools to return the overall heathstatus pass/fail


function QueryHDSmartStatus([string]$strDevice="/dev/hda")
{
	#function will output true/fall - true = overall health is "PASSED" and false is "FAILED"
	# $strDevice - linux/unix style nomenclature of the device to query (ex /dev/hda). Default is /dev/hda
	

	#output of the smartctl command to query the overall health status is stored in an array - each line is an entry in the array
	$arrSMTOutput = smartctl -H $strDevice 
	
	#searches for the entry containing the text "PASSED". 
	#Chose this method rather than hard-coding the exact line this information appears on. Finding it dynamically is more fault-tolerant
	for ($i=0; $i -le $arrSMTOutput.getupperbound(0); $i++)
	{
		If ($arrSMTOutput[$i] -match "PASSED" -eq $true) 
		{
			Return $true
			break #exits loop
		}
	}		
	#This will only run if it never found a match corresponding to the temperature which means the user put in invalid parameters
	Return $false
}
