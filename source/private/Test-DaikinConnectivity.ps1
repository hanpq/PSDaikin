function Test-DaikinConnectivity
{
    <#
        .DESCRIPTION
            Function tests connection to specified target
        .PARAMETER Hostname
            IP or FQDN for Daikin unit
        .EXAMPLE
            Test-DaikinConnectivity -Hostname daikin.network.com
            Returns true or false depending on if the device responds
    #>

    [CmdletBinding()] # Enabled advanced function support
    [OutputType([boolean])]
    param(
        [Parameter(Mandatory)]$Hostname
    )

    PROCESS
    {
        $SavedProgressPreference = $global:ProgressPreference
        $global:ProgressPreference = 'SilentlyContinue'
        try
        {
            if (Test-Connection -ComputerName $Hostname -Quiet -WarningAction SilentlyContinue)
            {
                return $true
            }
            else
            {
                return $false
            }
        }
        catch
        {
            throw "Failed to check status of daikin device with error: $PSItem"
        }
        finally
        {
            $global:ProgressPreference = $SavedProgressPreference
        }
    }

}
#endregion
