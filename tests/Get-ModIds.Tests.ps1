BeforeAll {
    Import-Module -Name '/lib'
}

Describe "Get-ModIds" {
    Context "Two mod ids set" {
        BeforeAll {
            $env:MOD_IDS = 'mod1,mod2'        
        }

        It "parses the mod ID variable" {
            Get-ModIds | Should -Be @('mod1', 'mod2')
        }
    }

    Context "One mod id set" {
        BeforeAll {
            $env:MOD_IDS = 'mod1'        
        }

        It "parses the mod ID variable" {
            Get-ModIds | Should -Be @('mod1')
        }
    }

    Context "No mod ids set" {
        BeforeAll {
            $env:MOD_IDS = $null      
        }

        It "parses the mod ID variable" {
            Get-ModIds | Should -Be @()
        }
    }
}
