BeforeAll {
    Import-Module -Name '/lib'
}

Describe "Start-StarboundServer" {

    AfterEach {
        Remove-Item -Path '/starbound/linux/starbound_server' -Force -ErrorAction SilentlyContinue
    }
    BeforeEach {
        Remove-Item -Path '/starbound/linux/starbound_server' -Force -ErrorAction SilentlyContinue
    }

    Context "Nothing is installed" {
        It "returns false" {
            Test-StarboundInstalled | Should -BeFalse
        }
    }

    Context "File present at install location" {
        BeforeEach {
            mkdir -p '/starbound/linux'
            touch '/starbound/linux/starbound_server' 
        }

        It "returns true" {
            Test-StarboundInstalled | Should -BeTrue
        }
    }
}