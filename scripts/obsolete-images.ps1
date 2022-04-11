param (
    [Parameter(Mandatory = $true)]
    [string[]] $usedVersions
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

function isUsed([string] $link)
{
    foreach ($version in $usedVersions)
    {
        if ($link.Contains($version))
        {
            return $true
        }
    }

    return $false
}

$links = (Invoke-WebRequest https://github.com/getsentry/unity-docker/pkgs/container/unity-docker/versions).Links.Href
$linksUnused = $links | Select-String -Pattern "tag=editor-ubuntu" | Where-Object { !(isUsed $_) }

if ($linksUnused.Length -gt 0)
{
    Write-Host "The following versions are not used, you can delete them now"
    foreach ($link in $linksUnused)
    {
        Write-Output "https://github.com/$link"
    }
    # Because we can't delete automatically yet, fail the CI here if there are any items the user needs to delete manually
    exit 1
}
else
{
    Write-Host "There are no unused versions, all ${$links.Length} are currently in use"
}