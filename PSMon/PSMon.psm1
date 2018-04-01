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
        ModuleRoot = $PSScriptRoot
        ConfigFile = "$PSScriptRoot\bin\PSMon.config"
    }

Export-ModuleMember -Variable PSMon
Export-ModuleMember -Function $Public.Basename

Init