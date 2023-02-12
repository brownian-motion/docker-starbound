BeforeAll {
    Import-Module -Name '/lib'
}

Describe "Get-StarboundConfigOverrideFlags" {
    BeforeEach { 
        Remove-Item Env:\STARBOUND_*  
    }
    AfterEach {
        Remove-Item Env:\STARBOUND_*  
    }

    It "returns nothing when no parameters are set" {
        Get-StarboundConfigOverrideFlags | Should -Be @()
    }

    It "sets config for fake 'test1' parameter" {
        $env:STARBOUND_test1 = 'value'    

        Get-StarboundConfigOverrideFlags | Should -Be @('-setconfig', 'test1:value')
    }

    It "parses the mod ID variable" {
        $env:STARBOUND_maxPlayers = '8'
        $env:STARBOUND_serverName = 'Name with spaces!'

        Get-StarboundConfigOverrideFlags | Should -Be @('-setconfig', 'maxPlayers:8', '-setconfig', 'serverName:Name with spaces!')
    }
}
