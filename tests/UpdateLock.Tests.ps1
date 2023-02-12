BeforeAll {
    Import-Module -Name '/lib'
}

Describe "Test-UpdateLock" {
    It "is locked when /.update is present" {
        touch /.update
        Test-UpdateLock | Should -Be $true
    }

    It "is locked when /.update is present" {
        Remove-Item -Force /.update -ErrorAction SilentlyContinue
        Test-UpdateLock | Should -Be $false
    }
}

Describe "Lock-UpdateLock" {
    It "locks when not locked" {
        Remove-Item -Force /.update -ErrorAction SilentlyContinue
        Test-UpdateLock | Should -Be $false
        Lock-UpdateLock
        Test-UpdateLock | Should -Be $true
    }

    It "stays locked when already locked" {
        touch /.update
        Test-UpdateLock | Should -Be $true
        Lock-UpdateLock
        Test-UpdateLock | Should -Be $true
    }
}

Describe "Unlock-UpdateLock" {
    It "stays unlocked when not locked" {
        Remove-Item -Force /.update -ErrorAction SilentlyContinue
        Test-UpdateLock | Should -Be $false
        Unlock-UpdateLock
        Test-UpdateLock | Should -Be $false
    }

    It "unlocks when locked" {
        touch /.update
        Test-UpdateLock | Should -Be $true
        Unlock-UpdateLock
        Test-UpdateLock | Should -Be $false
    }
}
