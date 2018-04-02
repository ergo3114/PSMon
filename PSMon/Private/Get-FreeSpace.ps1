function Get-FreeSpace{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        $ComputerName = $PSMon.ComputerName,

        [Parameter(Mandatory=$false)]
        [double]$WarningThreshold = 25,

        [Parameter(Mandatory=$false)]
        [double]$ErrorThreshold = 10
    )

    BEGIN{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has started"

        #region Variables
        Write-Verbose "Setting up variables"
        $Objects = New-Object System.Collections.ArrayList
        $ReturnedObjects = New-Object System.Collections.ArrayList
        try{
            if($ComputerName -ne $env:COMPUTERNAME){
                Write-Verbose "Attempting to get processor info from remote computer"
                $FreeSpaces = (Get-Counter -ComputerName $ComputerName "\logicaldisk(*:)\% free space" -ErrorAction Stop).CounterSamples
            } else{
                Write-Verbose "Attempting to get processor info from local computer"
                $FreeSpaces = (Get-Counter "\logicaldisk(*:)\% free space" -ErrorAction Stop).CounterSamples
            }
        } catch{
            Write-Error "$($PSItem.ToString())"
            break
        }
        #endregion
    }

    PROCESS{
        foreach($FreeSpace in $FreeSpaces){
            $objs = [pscustomobject]@{
                DriveLetter = $FreeSpace.InstanceName.ToUpper()
                Percentage = "$([math]::Round($FreeSpace.CookedValue,2))%"
            }
            $void = $Objects.Add($objs)
        }

        Write-Verbose "Getting logical data about processor"
        foreach($Object in $Objects){
            if([double]$Object.Percentage.Replace("%","") -le $ErrorThreshold){
                Write-Verbose "Processor met criteria for error"
                $Object = $Object | Select-Object *, @{n='Status';e={Write-Output 'Error'}}
                $void = $ReturnedObjects.Add($Object)
            } elseif([double]$Object.Percentage.Replace("%","") -le $WarningThreshold){
                Write-Verbose "Processor met criteria for warning"
                $Object = $Object | Select-Object *, @{n='Status';e={Write-Output 'Warning'}}
                $void = $ReturnedObjects.Add($Object)
            }
        }
        if($ReturnedObjects -eq $null){
            $void = $ReturnedObjects.Add('No_Matches')
        }
    }

    END{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed"
        return $ReturnedObjects
    }
}