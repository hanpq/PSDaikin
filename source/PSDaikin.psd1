#
# Module manifest for module 'PSDaikin'
#
# Generated by: Hannes Palmquist
#
# Generated on: 2022-11-13
#

@{
    RootModule           = 'PSDaikin.psm1'
    ModuleVersion        = '0.0.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    PowerShellVersion    = '5.1'
    GUID                 = 'c3de1a8c-042f-470c-b6b1-bceedbf199ef'
    Author               = 'Hannes Palmquist'
    CompanyName          = 'GetPS'
    Copyright            = '(c) Hannes Palmquist. All rights reserved.'
    Description          = 'Powershell Module to control a Daikin AirCon unit'
    RequiredModules      = @()
    FunctionsToExport    = '*'
    CmdletsToExport      = '*'
    VariablesToExport    = '*'
    AliasesToExport      = '*'
    PrivateData          = @{
        PSData = @{
            # Due to a bug in PowershellGet 3.0.17-beta17 licenseuri cannot used when Publishing.
            # Rollback to 3.0.17-beta16 has a bug that does not allow publishing of versioned powershell modules.
            # These three must be commented until 3.0.17-beta18 is released.
            #LicenseUri               = 'https://github.com/hanpq/PSDaikin/blob/main/LICENSE'
            #RequireLicenseAcceptance = $false
            ProjectUri   = 'https://getps.dev/modules/PSDaikin/getstarted'
            Prerelease   = ''
            Tags         = @('PSEdition_Desktop', 'PSEdition_Core', 'Windows', 'Linux', 'MacOS')
            ReleaseNotes = ''
        }
    }
}
