function Get-DaikinPollingConfiguration
{
    <#
        .DESCRIPTION
            Get Daikin polling configuration from unit
        .PARAMETER Hostname
            Defines the hostname of the Daikin unit
        .PARAMETER Raw
            Defines that no attribute name mapping should be done
        .EXAMPLE
            Get-DaikinPollingConfiguration
            Description of example
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        $Hostname,
        $Raw
    )
    PROCESS
    {
        try
        {
            $Result = Invoke-RestMethod -Uri ('http://{0}//common/get_remote_method' -f $Hostname) -Method GET -ErrorAction Stop
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
