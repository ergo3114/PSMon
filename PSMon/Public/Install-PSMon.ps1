function Install-PSMon{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [int]$PollingCycle = 15,

        [Parameter(Mandatory=$false)]
        [string]$EmailAddress = $null
    )

    #Create Scheduled Tasks based on parameters
    #Send to email if not null
}