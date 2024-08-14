# Changes tab-complete to display a menu instead of just tabbing through options.
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

#region Import Modules
$psgalleryRepo = Get-PSRepository | Where-Object {$_.Name -eq 'PSGallery'}

<#
    posh-git        adds autocompletion for git
    Terminal-Icons  adds glyphs for files and folders in the terminal
#>
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
        # List of modules that should be imported.
        [Parameter(Mandatory)]
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

#region PowerShell Completions

# chezmoi command tab completion
# Using $ENV:USERPROFILE because it doesn't exist in the Linux pwsh version, and therefore won't load this tab completion.
# I typically use pwsh within a containerized environment on Linux, where chezmoi is not likely setup.
$chezmoiCompletion = "$ENV:USERPROFILE/.config/powershell/completions/chezmoi.ps1"
if (Test-Path($chezmoiCompletion)) {
    . $chezmoiCompletion
}

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://docs.chocolatey.org/en-us/troubleshooting/#why-does-choco-tab-not-work-for-me
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Python pip command completions
# See https://pip.pypa.io/en/stable/user_guide/#command-completion
$pipCompletion = "$HOME/.config/powershell/completions/pip.ps1"
if (Test-Path($pipCompletion)) {
    . $pipCompletion
}

#endRegion

#region Custom Functions
function Get-PublicIP {
    (Invoke-WebRequest -Uri http://ifconfig.me/ip).Content    
}

function Get-EnvironmentVariables {
    Get-ChildItem -Path Env:/ | Sort-Object -Property Name
}

#endRegion

if (Get-Command -Name "starship" -ErrorAction SilentlyContinue) {
    # This starts up starship for prompt customization.
    Invoke-Expression (&starship init powershell)
} else {
    Write-Warning -Message "Starship Prompt not installed."
}

