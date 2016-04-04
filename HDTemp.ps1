#HDTemp.ps1
#written by Brenton Keegan on 8/9/2013 
#Used smartmontools to return the current temperature of a specified harddrive.
#Dependencies: this script requires smartmontools to be present and the bin directory to be in the PATH environmental variable -default install will do this
#http://sourceforge.net/apps/trac/smartmontools/wiki

function QueryHDTemp([string]$strDevice="/dev/hda",[boolean]$bolFahrenheit=$false)
{
	# $strDevice - linux/unix style nomenclature of the device to query (ex /dev/hda). Default is /dev/hda
	# $bolFahrenheit  - False = return degrees in celsius, True = Fahrenheit. Default is false

	#output of the smartctl command to query temperature is stored in an array - each line is an entry in the array
	$arrSMTOutput = smartctl -l scttemp $strDevice 
	
	#searches for the entry containing the text "Current Temperature". 
	#Chose this method rather than hard-coding the exact line this information appears on. Finding it dynamically is more fault-tolerant
	for ($i=0; $i -le $arrSMTOutput.getupperbound(0); $i++)
	{
		If ($arrSMTOutput[$i] -match "Current Temperature" -eq $true) 
		{
			#regex expression for any number of any length - [0-9]+ the "out-null expression prevents "True" being put in stdout
			$arrSMTOutput[$i] -match "[0-9]+" | out-null
			$fltTemperature =  [float]$matches[0] #converts match to floating point and stores in variable. needs to be float to convert to Fahrenheit (need decimal points for accurate calculation)
			If($bolFahrenheit -eq $true)
			{
				Return ConvertTemp $fltTemperature $true $true
			}
			Else
			{
				Return $fltTemperature 
			}
			break #exits loop
		}
	}		
	#This will only run if it never found a match corresponding to the temperature which means the user put in invalid parameters
	Return $arrSMTOutput
}

function ConvertTemp([float]$fltTemperature,[boolean]$bolCtoF=$true,[boolean]$bolRound=$true)
{
	#function by brenton keegan - written on 8/9/2013. Converts celsius to fahrenheit and vice-versa
	#params: 
	#		$fltTemperature - integer of the number to convert 
	#		$bolCtoF - Default is True. Will assume specified number is celsius and convert to fahrenheit - set to False to do vice-versa
	#		$bolRound - default is True - rounds result to nearest whole number
	
	if($bolCtoF -eq $true) 
	{
		$fltResult = ($fltTemperature*(9/5) + 32)
	}
	Else
	{
		$fltResult = ($fltTemperature - 32) * (5/9)
	}

	if($bolRound -eq $true)
	{
		Return [Math]::Round($fltResult)
	}
	Else
	{
		Return $fltResult
	}
	
}
