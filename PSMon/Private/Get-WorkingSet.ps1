function Get-WorkingSet{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        $ComputerName = $env:COMPUTERNAME,

        [Parameter(Mandatory=$false)]
        [double]$WarningThreshold = 10,

        [Parameter(Mandatory=$false)]
        [double]$ErrorThreshold = 20,

        [Parameter(Mandatory=$false)]
        [int]$Top = $null
    )

    BEGIN{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has started"

        #region Variables
        Write-Verbose "Setting up variables"
        $StagingObjects = New-Object System.Collections.ArrayList
        $ReturnedObjects = New-Object System.Collections.ArrayList
        try{
            if($ComputerName -ne $env:COMPUTERNAME){
                Write-Verbose "Attempting to get working set info from remote computer"
                $Processes = (Get-Counter -ComputerName $ComputerName "\Process(*)\ID Process" -ErrorAction Stop).CounterSamples | Where-Object {$_.InstanceName -ne "_total"}
                $WorkingSets = (Get-Counter -ComputerName $ComputerName ($Processes.Path -replace "\\id process$","\Working Set - Private") -ErrorAction Stop).CounterSamples
                $WSTotal = (Get-Counter -ComputerName $ComputerName "\Process(_total)\Working Set - Private" -ErrorAction Stop).CounterSamples.RawValue
            } else{
                Write-Verbose "Attempting to get working set info from local computer"
                $Processes = (Get-Counter "\Process(*)\ID Process" -ErrorAction Stop).CounterSamples | Where-Object {$_.InstanceName -ne "_total"}
                $WorkingSets = (Get-Counter ($Processes.Path -replace "\\id process$","\Working Set - Private") -ErrorAction Stop).CounterSamples
                $WSTotal = (Get-Counter "\Process(_total)\Working Set - Private" -ErrorAction Stop).CounterSamples.RawValue
            }
        } catch{
            Write-Error "$($PSItem.ToString())"
            break
        }
        #endregion
    }

    PROCESS{
        if($Top){
            Write-Verbose "Filtering to the top $Top highest items"
            $WorkingSets = $WorkingSets | Where-Object {$_.InstanceName -ne "_total"} | Sort-Object CookedValue -Descending | Select-Object * -First $Top
        }

        Write-Verbose "Cycling through each process"
        foreach($Process in $Processes){
            $SpecifiedPath = Split-Path $Process.Path
            $objs = [pscustomobject]@{
                PID = $Process.RawValue
                Name = $Process.InstanceName
                Value = [uint64]($WorkingSets | Where-Object {$_.Path -eq "$SpecifiedPath\Working Set - Private"}).RawValue
            }
            $void = $StagingObjects.Add($objs)
        }

        Write-Verbose "Getting logical data about processes"
        foreach($Object in $StagingObjects){
            $Percentage = ($Object.Value / $WSTotal) * 100
            if([double]$Percentage -ge $ErrorThreshold){
                Write-Verbose "$($Object.PID) - $($Object.Name) met criteria for error"
                $Object = $Object | Select-Object *, @{n='Percentage';e={Write-Output "$([math]::Round($Percentage,2))"}}, @{n='Status';e={Write-Output 'Error'}}
                $void = $ReturnedObjects.Add($Object)
            } elseif([double]$Percentage -ge $WarningThreshold){
                Write-Verbose "$($Object.PID) - $($Object.Name) met criteria for warning"
                $Object = $Object | Select-Object *, @{n='Percentage';e={Write-Output "$([math]::Round($Percentage,2))"}}, @{n='Status';e={Write-Output 'Warning'}}
                $void = $ReturnedObjects.Add($Object)
            } else{
                $void = $ReturnedObjects.Add('No_Matches')
            }
        }
    }

    END{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed"
        return $ReturnedObjects
    }
}