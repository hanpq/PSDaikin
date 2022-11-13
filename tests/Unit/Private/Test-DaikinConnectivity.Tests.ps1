BeforeDiscovery {
    $ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
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
    Describe -Name 'Test-DaikinConnectivity.ps1' -Fixture {
        Context -Name 'When able to connect to device' {
            BeforeAll {
                Mock Test-Connection -MockWith { return $true }
            }
            It -Name 'Should not throw' {
                { Test-DaikinConnectivity -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
            It -Name 'Return true' {
                Test-DaikinConnectivity -Hostname 'daikin.network.com' | Should -BeTrue
            }
        }
        Context -Name 'When unable to connect to device' {
            BeforeAll {
                Mock Test-Connection -MockWith { return $false }
            }
            It -Name 'Should not throw' {
                { Test-DaikinConnectivity -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
            It -Name 'Return false' {
                Test-DaikinConnectivity -Hostname 'daikin.network.com' | Should -BeFalse
            }
        }
        Context -Name 'When Test-NetConnection throws' {
            BeforeAll {
                Mock Test-Connection -MockWith { throw }
            }
            It -Name 'Should not throw' {
                { Test-DaikinConnectivity -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
}
