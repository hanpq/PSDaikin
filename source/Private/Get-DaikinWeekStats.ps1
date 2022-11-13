function Get-DaikinWeekStats
{
    <#
        .DESCRIPTION
            Get Daikin Week statistics from Daikin unit
        .PARAMETER Hostname
            Defines the hostname of the Daikin unit
        .PARAMETER Raw
            Defines that no attribute name mapping should be done
        .EXAMPLE
            Get-DaikinWeekStats
            Description of example
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Stat is short to static which is missleading')]
    [CmdletBinding()] # Enabled advanced function support
    param(
        $Hostname,
        $Raw
    )

    PROCESS
    {
        try
        {
            $Result = Invoke-RestMethod -Uri ('http://{0}/aircon/get_week_power' -f $Hostname) -Method GET -ErrorAction Stop
        }
        catch
        {
            throw $_.exception.message
        }

        try
        {
            $Result = Convert-DaikinResponse -String $Result -Raw:$Raw -ErrorAction Stop
        }
        catch
        {
            throw $_.exception.message
        }
        return $Result
    }
}
#endregion
