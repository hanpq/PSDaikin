function Get-DaikinBasicInfo
{
    <#
        .DESCRIPTION
            Retreives daikin basic info object
        .PARAMETER Hostname
            Defines the IP or hostname of the Daikin unit
        .EXAMPLE
            Get-DaikinBasicInfo -Hostname 192.168.1.1

            Returns the basic info response from the device
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        $Hostname
    )
    PROCESS
    {
        try
        {
            $Result = Invoke-RestMethod -Uri ('http://{0}/common/basic_info' -f $Hostname) -Method GET -ErrorAction Stop
        }
        catch
        {
            throw 'Failed to invoke rest method'
        }

        try
        {
            $Result = Convert-DaikinResponse -String $Result -ErrorAction Stop
        }
        catch
        {
            throw 'Failed to convert daikin response'
        }

        return $Result
    }
}
#endregion
