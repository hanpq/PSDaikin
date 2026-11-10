function Get-DaikinModelInfo
{
    <#
        .DESCRIPTION
            Get Daikin model info from unit
        .PARAMETER Hostname
            Defines the hostname of the Daikin unit
        .PARAMETER Raw
            Defines that no attribute name mapping should be done
        .EXAMPLE
            Get-DaikinModelInfo
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
            $Result = Invoke-RestMethod -Uri ('http://{0}/aircon/get_model_info' -f $Hostname) -Method GET -ErrorAction Stop
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
