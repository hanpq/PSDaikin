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

InModuleScope $ProjectName { Describe -Name 'Convert-DaikinResponse.ps1' -Fixture {
        BeforeAll {
            $ResponseString = 'ret=OK,pow=1,mode=7,adv=,stemp=22.0,shum=0,dt1=22.0,dt2=M,dt3=25.0,dt4=10.0,dt5=10.0,dt7=22.0,dh1=0,dh2=50,dh3=0,dh4=0,dh5=0,dh7=0,dhh=50,b_mode=7,b_stemp=22.0,b_shum=0,alert=255,f_rate=A,f_dir=0,b_f_rate=A,b_f_dir=0,dfr1=A,dfr2=5,dfr3=5,dfr4=A,dfr5=A,dfr6=5,dfr7=A,dfrh=5,dfd1=0,dfd2=0,dfd3=0,dfd4=0,dfd5=0,dfd6=0,dfd7=0,dfdh=0,dmnd_run=0,en_demand=0'
        }
        Context -Name 'When calling without raw' {
            It -Name 'Should not throw' {
                { Convert-DaikinResponse -String $ResponseString } | Should -Not -Throw
            }
            It -Name 'Should return a ordered dictionary' {
                Convert-DaikinResponse -String $ResponseString | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            }
            It -Name 'Should have count of 45' {
            (Convert-DaikinResponse -String $ResponseString).Keys | Should -HaveCount 45
            }
            It -Name 'Should have readable property names' {
            (Convert-DaikinResponse -String $ResponseString).Keys | Should -Contain 'TargetTemp'
            }
            It -Name 'Should have mode translated from int to string' {
            (Convert-DaikinResponse -String $ResponseString).Mode | Should -Be 'AUTO'
            }
        }
        Context -Name 'When calling with raw' {
            It -Name 'Should not throw' {
                { Convert-DaikinResponse -String $ResponseString -Raw } | Should -Not -Throw
            }
            It -Name 'Should return a ordered dictionary' {
                Convert-DaikinResponse -String $ResponseString -Raw | Should -BeOfType [System.Collections.Specialized.OrderedDictionary]
            }
            It -Name 'Should have count of 45' {
            (Convert-DaikinResponse -String $ResponseString -Raw).Keys | Should -HaveCount 45
            }
            It -Name 'Should have readable property names' {
            (Convert-DaikinResponse -String $ResponseString -Raw).Keys | Should -Contain 'stemp'
            }
            It -Name 'Should have mode translated from int to string' {
            (Convert-DaikinResponse -String $ResponseString -Raw).Mode | Should -Be '7'
            }
        }
        Context -Name 'Test all input options' {
            $TestCases = @(
                @{InputValue = 0; OutputValue = 'Auto' }
                @{InputValue = 1; OutputValue = 'Auto' }
                @{InputValue = 2; OutputValue = 'DRY' }
                @{InputValue = 3; OutputValue = 'COLD' }
                @{InputValue = 4; OutputValue = 'HEAT' }
                @{InputValue = 6; OutputValue = 'FAN' }
                @{InputValue = 7; OutputValue = 'Auto' }
            )
            It -Name 'Mode:<InputValue> translates to <OutputValue>' -TestCases $TestCases -Test {
                $ResponseString = ('ret=OK,pow=1,mode={0},adv=,stemp=22.0,shum=0,dt1=22.0,dt2=M,dt3=25.0,dt4=10.0,dt5=10.0,dt7=22.0,dh1=0,dh2=50,dh3=0,dh4=0,dh5=0,dh7=0,dhh=50,b_mode=7,b_stemp=22.0,b_shum=0,alert=255,f_rate=7,f_dir=0,b_f_rate=A,b_f_dir=0,dfr1=A,dfr2=5,dfr3=5,dfr4=A,dfr5=A,dfr6=5,dfr7=A,dfrh=5,dfd1=0,dfd2=0,dfd3=0,dfd4=0,dfd5=0,dfd6=0,dfd7=0,dfdh=0,dmnd_run=0,en_demand=0' -f $inputvalue)
            (Convert-DaikinResponse -String $ResponseString).Mode | Should -Be $outputvalue
            }
            $TestCases = @(
                @{InputValue = 'A'; OutputValue = 'Auto' }
                @{InputValue = 'B'; OutputValue = 'Silent' }
                @{InputValue = 3; OutputValue = 'Level_1' }
                @{InputValue = 4; OutputValue = 'Level_2' }
                @{InputValue = 5; OutputValue = 'Level_3' }
                @{InputValue = 6; OutputValue = 'Level_4' }
                @{InputValue = 7; OutputValue = 'Level_5' }
            )
            It -Name 'FanSpeed:<InputValue> translates to <OutputValue>' -TestCases $TestCases -Test {
                $ResponseString = ('ret=OK,pow=1,mode=2,adv=,stemp=22.0,shum=0,dt1=22.0,dt2=M,dt3=25.0,dt4=10.0,dt5=10.0,dt7=22.0,dh1=0,dh2=50,dh3=0,dh4=0,dh5=0,dh7=0,dhh=50,b_mode=7,b_stemp=22.0,b_shum=0,alert=255,f_rate={0},f_dir=0,b_f_rate=A,b_f_dir=0,dfr1=A,dfr2=5,dfr3=5,dfr4=A,dfr5=A,dfr6=5,dfr7=A,dfrh=5,dfd1=0,dfd2=0,dfd3=0,dfd4=0,dfd5=0,dfd6=0,dfd7=0,dfdh=0,dmnd_run=0,en_demand=0' -f $inputvalue)
            (Convert-DaikinResponse -String $ResponseString).FanSpeed | Should -Be $outputvalue
            }
            $TestCases = @(
                @{InputValue = 0; OutputValue = 'Stopped' }
                @{InputValue = 1; OutputValue = 'VerticalSwing' }
                @{InputValue = 2; OutputValue = 'HorizontalSwing' }
                @{InputValue = 3; OutputValue = 'BothSwing' }
            )
            It -Name 'FanDirection:<InputValue> translates to <OutputValue>' -TestCases $TestCases -Test {
                $ResponseString = ('ret=OK,pow=1,mode=2,adv=,stemp=22.0,shum=0,dt1=22.0,dt2=M,dt3=25.0,dt4=10.0,dt5=10.0,dt7=22.0,dh1=0,dh2=50,dh3=0,dh4=0,dh5=0,dh7=0,dhh=50,b_mode=7,b_stemp=22.0,b_shum=0,alert=255,f_rate=4,f_dir={0},b_f_rate=A,b_f_dir=0,dfr1=A,dfr2=5,dfr3=5,dfr4=A,dfr5=A,dfr6=5,dfr7=A,dfrh=5,dfd1=0,dfd2=0,dfd3=0,dfd4=0,dfd5=0,dfd6=0,dfd7=0,dfdh=0,dmnd_run=0,en_demand=0' -f $inputvalue)
            (Convert-DaikinResponse -String $ResponseString).FanDirection | Should -Be $outputvalue
            }
        }
    }
}
