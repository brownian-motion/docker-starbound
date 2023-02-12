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
        It "throws an exception" {
            { Start-StarboundServer } | Should -Throw -ExpectedMessage "Starbound not installed, please run /update.ps1 for initial install"
        }
    }

    Context "Locked for update" {
        BeforeEach {
            touch /.update
            mkdir -p '/starbound/linux'
            ln -s '/bin/false' '/starbound/linux/starbound_server' 
        }

        It "throws an exception" {
            { Start-StarboundServer } | Should -Throw -ExpectedMessage "Locked for update, please run /update.ps1 for initial install or update"
        }
    }

    # todo: refuse to start unless installed mod list = requested mod list?

    Context "Fully installed and always finishes successfully" {
        BeforeEach {
            mkdir -p '/starbound/linux'
            ln -s '/bin/true' '/starbound/linux/starbound_server' 
            Remove-Item -Force /.update -ErrorAction SilentlyContinue
        }

        It "returns exit code 0" {
            Start-StarboundServer | Should -Be 0
        }
    }


    Context "Fully installed and always exits with 1" {
        BeforeEach {
            mkdir -p '/starbound/linux'
            touch '/starbound/linux/starbound_server'
            Add-Content -Path '/starbound/linux/starbound_server' '#!/bin/bash'
            Add-Content -Path '/starbound/linux/starbound_server' 'exit 1'
            chmod u+rx '/starbound/linux/starbound_server'
        }

        It "returns exit code 1" {
            Start-StarboundServer | Should -Be 1
        }
    }
}