# Changes tab-complete to display a menu instead of just tabbing through options.
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

#region Import Modules
$psgalleryRepo = Get-PSRepository | Where-Object {$_.Name -eq 'PSGallery'}

$Modules = @(
    "posh-git",
    "Terminal-Icons"
)

if ($psgalleryRepo.InstallationPolicy -ne 'Trusted') {
    Write-Warning "PSGallery repository is not trusted."
    $trustPSGallery = Read-Host -Prompt "Do you want to trust PSGallery? (Y/N)"

    if ($trustPSGallery -eq 'Y') {
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    }
}

function Import-ModuleList {
    [CmdletBinding()]
    param (
        [string[]]$Modules
    )
    
    process {
        foreach ($currentModule in $Modules) {
            if (Get-Module -ListAvailable -Name $currentModule) {
                Import-Module -Name $currentModule
            } else {
                Write-Warning "Module $currentModule is not installed."
                $installModule = Read-Host "Do you want to install $currentModule now? (Y/N)"

                if ($installModule -eq 'Y') {
                    Install-Module -Name $currentModule -Scope CurrentUser
                    Import-Module -Name $currentModule
                }
            }
        }
    }
}

Import-ModuleList -Modules $Modules
#endRegion

if (Get-Command -Name "starship" -ErrorAction SilentlyContinue) {
    # This starts up starship for prompt customization.
    Invoke-Expression (&starship init powershell)
} else {
    Write-Warning -Message "Starship Prompt not installed."
}

