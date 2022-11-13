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
                }) }
    ).BaseName

    Import-Module $ProjectName
}

InModuleScope $ProjectName {
    Describe -Name 'Get-DaikinControlInfo.ps1' -Fixture {
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
                { Get-DaikinControlInfo -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
        }
        Context -Name 'When Invoke-RestMethod fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinControlInfo -Hostname 'daikin.network.com' } | Should -Throw
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
                { Get-DaikinControlInfo -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }

}
