function Install-Monitoring{
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$false)]
        [int]$PollingCycle = 15,

        [Parameter(Mandatory=$false)]
        [string]$EmailAddress = $null,

        [Parameter(ParameterSetName="Repair")]
        [switch]$Repair
    )

    BEGIN{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has started"

        if($Repair){
            Write-Verbose "Running Init"
            Init
            SchTsk
            Return
        }
    }

    PROCESS{
        #region Scheduled Task
        SchTsk -PollingCycle $PollingCycle
        #endregion
    }

    END{
        Write-Verbose "[$(Get-Date)] $($MyInvocation.MyCommand) has completed"
    }
    #Create Scheduled Tasks based on parameters
    #Send to email if not null
}