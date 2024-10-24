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
    Describe 'Assert-FolderExist' {
        Context 'Default' {
            It 'Folder is created' {
                'TestDrive:\FolderDoesNotExists' | Assert-FolderExist
                'TestDrive:\FolderDoesNotExists' | Should -Exist
            }

            It 'Folder is still present' {
                New-Item -Path 'TestDrive:\FolderExists' -ItemType Directory
                'TestDrive:\FolderExists' | Assert-FolderExist
                'TestDrive:\FolderExists' | Should -Exist
            }
        }
    }
    Describe 'Convert-DaikinResponse' -Fixture {
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
    Describe 'Get-DaikinBasicInfo' -Fixture {
        Context -Name 'When retreival succeeds' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith {}
                function Convert-DaikinResponse
                {
                }
                Mock Convert-DaikinResponse -MockWith { return [ordered]@{} }
            }
            It -Name 'Should not throw' {
                { Get-DaikinBasicInfo -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
        }
        Context -Name 'When Invoke-RestMethod fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinBasicInfo -Hostname 'daikin.network.com' } | Should -Throw
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
                { Get-DaikinBasicInfo -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
    Describe 'Get-DaikinControlInfo' -Fixture {
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
    Describe 'Get-DaikinModelInfo' -Fixture {
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
                { Get-DaikinModelInfo -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
        }
        Context -Name 'When Invoke-RestMethod fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinModelInfo -Hostname 'daikin.network.com' } | Should -Throw
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
                { Get-DaikinModelInfo -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
    Describe 'Get-DaikinPollingConfiguration' -Fixture {
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
                { Get-DaikinPollingConfiguration -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
        }
        Context -Name 'When Invoke-RestMethod fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinPollingConfiguration -Hostname 'daikin.network.com' } | Should -Throw
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
                { Get-DaikinPollingConfiguration -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
    Describe 'Get-DaikinSensorInfo' -Fixture {
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
                { Get-DaikinSensorInfo -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
        }
        Context -Name 'When Invoke-RestMethod fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinSensorInfo -Hostname 'daikin.network.com' } | Should -Throw
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
                { Get-DaikinSensorInfo -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
    Describe 'Get-DaikinWeekStats' -Fixture {
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
                { Get-DaikinWeekStats -Hostname 'daikin.network.com' } | Should -Not -Throw
            }
        }
        Context -Name 'When Invoke-RestMethod fails' {
            BeforeAll {
                Mock Invoke-RestMethod -MockWith { throw }
            }
            It -Name 'Should throw' {
                { Get-DaikinWeekStats -Hostname 'daikin.network.com' } | Should -Throw
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
                { Get-DaikinWeekStats -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
    Describe 'Get-DaikinYearStats' -Fixture {
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
    Describe 'Invoke-GarbageCollect' {
        Context 'Default' {
            It 'Should not throw' {
                { Invoke-GarbageCollect } | Should -Not -Throw
            }
        }
    }
    Describe 'pslog' {
        BeforeAll {
            Mock -CommandName Get-Date -MockWith { [datetime]'2000-01-01 01:00:00+00:00' }
            $CompareString = ([datetime]'2000-01-01 01:00:00+00:00').ToString('yyyy-MM-ddThh:mm:ss.ffffzzz')
        }
        Context 'Success' {
            It 'Log file should have content' {
                pslog -Severity Success -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tSuccess`tdefault`tMessage"
            }
        }
        Context 'Info' {
            It 'Log file should have content' {
                pslog -Severity Info -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tInfo`tdefault`tMessage"
            }
        }
        Context 'Warning' {
            It 'Log file should have content' {
                pslog -Severity Warning -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tWarning`tdefault`tMessage"
            }
        }
        Context 'Error' {
            It 'Log file should have content' {
                pslog -Severity Error -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tError`tdefault`tMessage"
            }
        }
        Context 'Verbose' {
            It 'Log file should have content' {
                pslog -Severity Verbose -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole -Verbose:$true
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tVerbose`tdefault`tMessage"
            }
        }
        Context 'Debug' {
            It 'Log file should have content' {
                pslog -Severity Debug -Message 'Message' -LogDirectoryOverride 'TestDrive:\Logs' -DoNotLogToConsole -Debug:$true
                Get-Content 'TestDrive:\Logs\2000-01-01.log' | Should -BeExactly "$CompareString`tDebug`tdefault`tMessage"
            }
        }
    }
    Describe 'Resolve-DaikinHostname' -Fixture {
        BeforeAll {
        }
        Context -Name 'When calling with a valid IP address that responds' {
            BeforeAll {
                function Test-DaikinConnectivity
                {
                }
                Mock Test-DaikinConnectivity -MockWith { return $true }
            }
            It -Name 'It should not throw' -Test {
                { Resolve-DaikinHostname -Hostname '192.168.1.1' } | Should -Not -Throw
            }
            It -Name 'It should return 192.168.1.1' -Test {
                Resolve-DaikinHostname -HostName '192.168.1.1' | Should -Be '192.168.1.1'
            }
        }
        Context -Name 'When calling with a valid FQDN that responds' {
            BeforeAll {
                function Test-DaikinConnectivity
                {
                }
                Mock Test-DaikinConnectivity -MockWith { return $true }
            }
            It -Name 'It should not throw' -Test {
                { Resolve-DaikinHostname -Hostname 'localhost' } | Should -Not -Throw
            }
            It -Name 'It should return 192.168.1.1' -Test {
                Resolve-DaikinHostname -HostName 'localhost' | Should -Be '127.0.0.1'
            }
        }
        Context -Name 'When calling with a valid FQDN but IP resolution fails' {
            BeforeAll {
                function Test-DaikinConnectivity
                {
                }
                Mock Test-DaikinConnectivity -MockWith { return $true }
                function internal_resolvednsname
                {
                }
                Mock internal_resolvednsname -MockWith { throw }
            }
            It -Name 'It should throw' -Test {
                { Resolve-DaikinHostname -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
        Context -Name 'When calling with a valid FQDN that does not respond' {
            BeforeAll {
                function Test-DaikinConnectivity
                {
                }
                Mock Test-DaikinConnectivity -MockWith { return $false }
            }
            It -Name 'It should throw' {
                { Resolve-DaikinHostname -Hostname 'daikin.network.com' } | Should -Throw
            }
        }
    }
    Describe 'Test-DaikinConnectivity' -Fixture {
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
    Describe 'Write-PSProgress' {
        Context 'Default' {
            It 'Should not throw' {
                $ProgressPreference = 'SilentlyContinue'
                {
                    1..5 | ForEach-Object -Begin { $StartTime = Get-Date } -Process {
                        Write-PSProgress -Activity 'Looping' -Target $PSItem -Counter $PSItem -Total 5 -StartTime $StartTime
                    }
                } | Should -Not -Throw
            }
        }
    }
}
