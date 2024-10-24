BeforeDiscovery {
    $RootItem = Get-Item $PSScriptRoot
    while ($RootItem.GetDirectories().Name -notcontains 'source')
    {
        $RootItem = $RootItem.Parent
    }
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
                }) }
    ).BaseName

    Import-Module $ProjectName -Force
}

InModuleScope $ProjectName {
    Describe 'Get-DaikinStatus' -Fixture {
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

    Describe 'Set-DaikinAirCon' -Fixture {
        BeforeAll {
            function Convert-DaikinResponse
            {
            }
            Mock -CommandName Convert-DaikinResponse {
                [pscustomobject]@{
                    ret = 'OK'
                }
            }
            Mock -CommandName Invoke-RestMethod {}

            function Get-DaikinControlInfo
            {
                $Hostname,
                $Raw
            }
            Mock -CommandName Get-DaikinControlInfo -MockWith {
                [pscustomobject]@{
                    pow    = $true
                    mode   = 1
                    stemp  = 22
                    shum   = 22
                    f_rate = 'Level_1'
                    f_dir  = 'VerticalSwing'
                }
            }
            Mock Write-Host -MockWith {}
        }
        Context -Name 'When setting mode' {
            It 'Should not throw' {
                { Set-DaikinAirCon -HostName 'daikin.contoso.com' -Mode Auto } | Should -Not -Throw
            }
        }
        Context -Name 'When setting Temp' {
            It 'Should not throw' {
                { Set-DaikinAirCon -HostName 'daikin.contoso.com' -Temp 22 } | Should -Not -Throw
            }
        }
        Context -Name 'When setting PowerOn' {
            It 'Should not throw' {
                { Set-DaikinAirCon -HostName 'daikin.contoso.com' -PowerOn:$true } | Should -Not -Throw
            }
        }
        Context -Name 'When setting FanSpeed' {
            It 'Should not throw' {
                { Set-DaikinAirCon -HostName 'daikin.contoso.com' -FanSpeed AUTO } | Should -Not -Throw
            }
        }
        Context -Name 'When setting FanDirection' {
            It 'Should not throw' {
                { Set-DaikinAirCon -HostName 'daikin.contoso.com' -FanDirection HorizontalSwing } | Should -Not -Throw
            }
        }
        Context -Name 'When configuration fails with non OK response' {
            BeforeAll {
                function Convert-DaikinResponse
                {
                }
                Mock -CommandName Convert-DaikinResponse {
                    [pscustomobject]@{
                        ret = 'PARAM NG'
                    }
                }
            }
            It 'Should throw' {
                { Set-DaikinAirCon -HostName 'daikin.contoso.com' -Mode Auto } | Should -Throw
            }
        }
        Context -Name 'When stemp or shum is "--"' {
            BeforeAll {
                function Get-DaikinControlInfo
                {
                    $Hostname,
                    $Raw
                }
                Mock -CommandName Get-DaikinControlInfo -MockWith {
                    [pscustomobject]@{
                        pow    = $true
                        mode   = 1
                        stemp  = '--'
                        shum   = '--'
                        f_rate = 'Level_1'
                        f_dir  = 'VerticalSwing'
                    }
                }
            }
            It 'Should throw' {
                { Set-DaikinAirCon -HostName 'daikin.contoso.com' -Mode Auto } | Should -Not -Throw
            }
        }
    }
}
