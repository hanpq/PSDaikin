BeforeDiscovery {
        $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains "source") {$RootItem = $RootItem.Parent}
    $ProjectPath = $RootItem.FullName
    $ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object {
            ($_.Directory.Name -eq 'source') -and
            $(try
                {
                    Test-ModuleManifest $_.FullName -ErrorAction Stop
                }
                catch
                {
                    $false
                })
        }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe -Name 'Get-DaikinStatus.ps1' -Fixture {
        BeforeAll {
        }
        Context -Name 'When retreival succeeds' {
            BeforeAll {
                function Resolve-DaikinHostname
                {
                }
                Mock Resolve-DaikinHostname -MockWith { return '1.1.1.1' }
                function Get-DaikinControlInfo
                {
                }
                Mock Get-DaikinControlInfo -MockWith {
                    [pscustomobject]@{
                        PowerOn        = 1
                        Mode           = 1
                        TargetTemp     = 1
                        TargetHumidity = 1
                        FanSpeed       = 1
                        FanDirection   = 1
                    }
                }
                function Get-DaikinBasicInfo
                {
                }
                Mock Get-DaikinBasicInfo -MockWith {
                    [pscustomobject]@{
                        DeviceType = 1
                        Region     = 1
                        Version    = '1'
                        Revision   = 1
                        port       = 1
                        Identity   = 1
                        mac        = 1
                    }
                }
                function Get-DaikinSensorInfo
                {
                }
                Mock Get-DaikinSensorInfo -MockWith {
                    [PSCustomObject]@{
                        InsideTemp     = 1
                        InsideHumidity = 1
                        OutsideTemp    = 1
                    }
                }
            }
            It -Name 'Should not throw' {
                { Get-DaikinStatus -HostName 'daikin.network.com' } | Should -Not -Throw
            }
            It -Name 'Output values should flow through' {
                $Result = Get-DaikinStatus -HostName 'daikin.network.com'
                $Result.psobject.properties.where( { $PSItem.Name -ne 'Version' }).value.foreach( { [int]$PSItem | Should -Be 1 })
            }
        }
    }
}
