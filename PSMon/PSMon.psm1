#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
    $Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

#Setup PSMon variable
    $PSMon = @{
        Mode = "Server" #Client
        Root = $PSScriptRoot
        ConfigFile = "$PSScriptRoot\bin\PSMon.config"
        Start = "$PSScriptRoot\Public\Get-Monitoring.ps1"
        ScheduledTask = @{
            Monitoring = "PSMon-Monitoring"
        }
        DefaultOutput = "pscustomobject" #HTML, JSON
        ComputerName = $env:COMPUTERNAME
    }

Export-ModuleMember -Variable PSMon
Export-ModuleMember -Function $Public.Basename

Init