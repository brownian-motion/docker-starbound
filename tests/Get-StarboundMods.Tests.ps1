BeforeAll {
    Import-Module -Name '/lib'
}

Describe "Get-StarboundMods" {
    ## Cannot test this in CI/CD without having access to actual Steam login credentials
#     It "downloads a single mod to the steam directory" {
#         # mod '729427744' is 'Instant Crafting' and has been online since 2016. 
#         # It probably won't ever be removed, but feel free to use ANY mod id here (just keep it small!)
#         Test-Path "/starbound/steamapps/workshop/content/211820/729427744" | Should -BeFalse
#         Get-StarboundMods '729427744'
#         Test-Path "/starbound/steamapps/workshop/content/211820/729427744" | Should -BeTrue
#     }

    It "triggers a download command for two mods" {
        $savedArgs = @()
        Mock -Module 'lib' Invoke-SteamCmd { 
            $Command | Should -Be @(
                '+force_install_dir', '/starbound/', 
                '+login', 'foo', 
                '+workshop_download_item', '211820', 'MOD_1',
                '+workshop_download_item', '211820', 'MOD_2',
                '+quit'
            )
         } -Verifiable

        Get-StarboundMods -SteamUsername 'foo' -ModIds:@('MOD_1', 'MOD_2')
    }


    It "triggers a download command for one mod" {
        $savedArgs = @()
        Mock -Module 'lib' Invoke-SteamCmd { 
            $Command | Should -Be @(
                '+force_install_dir', '/starbound/', 
                '+login', 'foo', 
                '+workshop_download_item', '211820', 'MOD_1',
                '+quit'
            )
         } -Verifiable

        Get-StarboundMods -SteamUsername 'foo' -ModIds:@('MOD_1')
    }
}
