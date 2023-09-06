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
    Describe -Name 'Get-DaikinYearStats.ps1' -Fixture {
        BeforeAll {
        }
        Context -Name 'When retreival succeeds' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith {}
                function Convert-DaikinResponse
                {
                }
                Mock Convert-DaikinResponse -MockWith { return [ordered]@{} }
            }
            It -Name 'Should not throw' {
                { Get-DaikinYearStats -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
        }
        Context -Name 'When Invoke-RestMethod fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinYearStats -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
        Context -Name 'When Convert-DaikinResponse fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith {}
                function Convert-DaikinResponse
                {
                }
                Mock Convert-DaikinResponse -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinYearStats -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
}
