function Get-DaikinStatus
{
    <#
        .DESCRIPTION
            Retreives the current configuration of the Daikin AirCon device
        .PARAMETER Hostname
            Hostname or IP of the Daikin Aircon device.
        .EXAMPLE
            Get-DaikinStatus -Hostname daikin.local.network

            PowerOn        : True
            Mode           : HEAT
            TargetTemp     : 22.0
            ...
    #>

    [CmdletBinding()] # Enabled advanced function support
    param(
        $HostName
    )

    BEGIN
    {
        $Hostname = Resolve-DaikinHostname -Hostname:$Hostname
        $ControlInfo = Get-DaikinControlInfo -Hostname:$HostName
        Write-Verbose -Message 'Collected ControlInfo via REST API'
        # $ModelInfo = Get-DaikinModelInfo -Hostname:$HostName
        # Write-Verbose -Message 'Collected ModelInfo via REST API'
        $BasicInfo = Get-DaikinBasicInfo -Hostname:$HostName
        Write-Verbose -Message 'Collected BasicInfo via REST API'
        $SensorInfo = Get-DaikinSensorInfo -HostName:$HostName
        Write-Verbose -Message 'Collected SensorInfo via REST API'
    }

    PROCESS
    {
        $ObjectHash = [ordered]@{
            'PowerOn'        = $ControlInfo.PowerOn
            'Mode'           = $ControlInfo.Mode
            'TargetTemp'     = $ControlInfo.TargetTemp
            'TargetHumidity' = $ControlInfo.TargetHumidity
            'FanSpeed'       = $ControlInfo.FanSpeed
            'FanDirection'   = $ControlInfo.FanDirection
            'InsideTemp'     = $SensorInfo.InsideTemp
            'InsideHumidity' = $SensorInfo.InsideHumidity
            'OutsideTemp'    = $SensorInfo.OutsideTemp
            'DeviceType'     = $BasicInfo.DeviceType
            'Region'         = $BasicInfo.Region
            'Version'        = $BasicInfo.Version.Replace('_', '.')
            'Revision'       = $BasicInfo.Revision
            'Port'           = $BasicInfo.port
            'Identity'       = $BasicInfo.Identity
            'MACAddress'     = $BasicInfo.mac
        }
        return [pscustomobject]$ObjectHash
    }
}
#endregion
