function SchTsk{
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [int]$PollingCycle = 15
    )
    try{
        Unregister-ScheduledJob -Name $PSMon.ScheduledTask.Monitoring -ErrorAction Stop
    }
    catch{}
    finally{
        $Job = Register-ScheduledJob -Name "$($PSMon.ScheduledTask.Monitoring)" -FilePath "$($PSMon.Start)"
        $RepeatTrigger = New-JobTrigger -Once -At (Get-Date -Minute 00 -Second 00).ToShortTimeString() -RepetitionInterval (New-TimeSpan -Minutes $PollingCycle) -RepeatIndefinitely
        Add-JobTrigger -InputObject $Job -Trigger $RepeatTrigger
    }
}