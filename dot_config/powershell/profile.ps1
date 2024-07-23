# Changes tab-complete to display a menu instead of just tabbing through options.
Set-PSReadLineKeyHandler -Chord Tab -Function MenuComplete

if (Get-Command -Name "starship" -ErrorAction SilentlyContinue) {
    # This starts up starship for prompt customization.
    Invoke-Expression (&starship init powershell)
} else {
    Write-Warning -Message "Starship Prompt not installed."
}

