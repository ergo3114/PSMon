function Get-Processor{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        $ComputerName = $PSMon.ComputerName,

        [Parameter(Mandatory=$false)]
        [double]$WarningThreshold = 80,

        [Parameter(Mandatory=$false)]
        [double]$ErrorThreshold = 90
    )

    BEGIN{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has started"

        #region Variables
        Write-Verbose "Setting up variables"
        $Object = New-Object System.Collections.ArrayList
        $ReturnedObjects = New-Object System.Collections.ArrayList
        try{
            if($ComputerName -ne $env:COMPUTERNAME){
                Write-Verbose "Attempting to get processor info from remote computer"
                $ProcessorTotal = (Get-Counter -ComputerName $ComputerName "\processor(_total)\% processor time" -ErrorAction Stop).CounterSamples
            } else{
                Write-Verbose "Attempting to get processor info from local computer"
                $ProcessorTotal = (Get-Counter "\processor(_total)\% processor time" -ErrorAction Stop).CounterSamples
            }
        } catch{
            Write-Error "$($PSItem.ToString())"
            break
        }
        #endregion
    }

    PROCESS{
        $objs = [pscustomobject]@{
            Percentage = "$([math]::Round($ProcessorTotal.CookedValue,2))%"
        }
        $void = $Object.Add($objs)

        Write-Verbose "Getting logical data about processor"
        if([double]$Object.Percentage.Replace("%","") -ge $ErrorThreshold){
            Write-Verbose "Processor met criteria for error"
            $Object = $Object | Select-Object *, @{n='Status';e={Write-Output 'Error'}}
            $void = $ReturnedObjects.Add($Object)
        } elseif([double]$Object.Percentage.Replace("%","") -ge $WarningThreshold){
            Write-Verbose "Processor met criteria for warning"
            $Object = $Object | Select-Object *, @{n='Status';e={Write-Output 'Warning'}}
            $void = $ReturnedObjects.Add($Object)
        } else{
            $void = $ReturnedObjects.Add('No_Matches')
        }
    }

    END{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed"
        return $ReturnedObjects
    }
}