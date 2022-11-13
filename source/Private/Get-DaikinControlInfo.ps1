function Get-DaikinControlInfo
{
    <#
        .DESCRIPTION
            Retrevies daikin control info response and optionally converts it into a more readable format
        .PARAMETER Hostname
            Defines the hostname of the Daikin unit
        .PARAMETER Raw
            Defines that no attribute name mapping should be done
        .EXAMPLE
            Get-DaikinControlInfo -hostname daikin.network.com
            Returns the control info object converted to a readable format
        .EXAMPLE
            Get-DaikinControlInfo -hostname -daikin.network.com -raw
            Returns the control info object with as-is property names
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        [Parameter(Mandatory)]$Hostname,
        [switch]$Raw
    )
    PROCESS
    {
        try
        {
            $Result = Invoke-RestMethod -Uri ('http://{0}/aircon/get_control_info' -f $Hostname) -Method GET -ErrorAction Stop
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
