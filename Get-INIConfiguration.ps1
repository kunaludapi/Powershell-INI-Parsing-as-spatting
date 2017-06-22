function Get-IniConfiguration {
    ##############################
    #.SYNOPSIS
    #Convert INI data information to Hashtable for splatting
    #
    #.DESCRIPTION
    #The Get-IniConfiguration cmdlet fetch information from .ini file, and convert it to hashtable, This Hastable can be used later further as splatting. This is best for non technical users, and don't want to make any changes to script.
    #
    #.PARAMETER File
    #This is a File path. Extension can be .txt, .ini, .info or any other readable ascii file is supported, Below is the example content of file related to service.
    #[service]
    #Name=LanManServer
    #ComputerName=Localhost
    #
    #.PARAMETER Conf
    #This is a paramenter block mentioned in brackets, and same name variable created for splatting ie
    #[service] 
    #
    #.EXAMPLE
    #Get-IniConfiguration -File C:\temp\configuration.ini -Conf Service
    #Get-Service @Service
    #
    #Information is stored under $service (same name as -conf variable)
    #
    #.NOTES
    #http://vcloud-lab.com
    #Written using powershell version 5
    #Script code version 1.0
    ###############################
    
    [CmdletBinding()]
	param(
	    [Parameter(Position=0, Mandatory=$true)]
        [ValidateScript({
            If (Test-Path $_) {
                $true
            }
            else{
                "Invalid path given: $_"
            }
        })]
        [System.String]$File = 'C:\Temp\Test.ini',
		[Parameter(Position=1, Mandatory=$true)]
		[System.String]$Conf 
    )    
    $inifile = Get-Content -Path $File #-Raw -split '`r`n'
    $LineCounts = $iniFile.Count
    $ConfLineNumber = $iniFile | Select-String -Pattern "\[$Conf\]" | Select-Object -ExpandProperty LineNumber
    if ($ConfLineNumber -eq $null) {
        Write-Host "Please provide correct configuration name in -Conf parameter" -BackgroundColor DarkRed
        Break
    }
    $RawContext = $iniFile[$ConfLineNumber..$LineCounts] | Where-Object {$_.trim() -ne "" -and $_.trim() -notmatch "^;"}
    $FinalLineNumber = $RawContext | Select-String -Pattern "\[*\]" | Select-Object -First 1 -ExpandProperty LineNumber
    $FinalLineNumber = $FinalLineNumber - 1
    if ($FinalLineNumber -ge 1) {
        $FinalData = $RawContext | Select-Object -First $FinalLineNumber
        $FinalData = $FinalData | Where-Object {$_ -match "="}
    }
    else {
        $FinalData = $RawContext | Where-Object {$_ -match "="}
    }
    New-Variable -Scope Script -Name $Conf -Value ($FinalData | Out-String | ConvertFrom-StringData) -Force
}

Get-IniConfiguration -File .\Configuration.ini -Conf Service
Get-Service @Service
