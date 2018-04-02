function Uninstall-Monitoring{
    [cmdletbinding(SupportsShouldProcess)]
    Param()

    BEGIN{}

    PROCESS{
        if ($pscmdlet.ShouldProcess($PSMon.ScheduledTask.Monitoring, "Removing Scheduled Task")){
            try{
                Unregister-ScheduledJob -Name $PSMon.ScheduledTask.Monitoring -ErrorAction Stop
            }
            catch{}
        }
    }

    END{}
}