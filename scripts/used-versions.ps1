$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$repository = "https://github.com/getsentry/sentry-unity.git"
$checkoutDir = "temp-checkout"
$versionsScript = "scripts/ci-env.ps1"
$versionsBases = @("unity2019", "unity2020", "unity2021", "unity2022")

if (Test-Path $checkoutDir)
{
    Write-Host "Checkout dir already exists, removing"
    Remove-Item -Recurse -Force $checkoutDir
}
git clone -v $repository $checkoutDir

try
{
    $resultSet = New-Object System.Collections.Generic.HashSet[string]

    Push-Location $checkoutDir
    $branches = git for-each-ref --format='%(refname:short)' refs/remotes/origin/
    foreach ($branch in $branches)
    {
        git checkout --quiet $branch
        if (!(Test-Path $versionsScript))
        {
            Write-Warning "Skipping branch $branch - $versionsScript not found"
            continue
        }
        foreach ($arg in $versionsBases)
        {
            try
            {
                $usedVersion = & $versionsScript $arg
                Write-Host "Branch $branch uses $usedVersion"
                $resultSet.Add($usedVersion) > $null
            }
            catch
            {
                $exception = $_
                if (!($exception.ToString().Replace('Unkown', 'Unknown').StartsWith('Unknown variable')))
                {
                    Write-Error "Failed to determine exact version for '$arg' on branch $branch - $exception"
                }
            }
        }
    }
    Write-Host "-----------------------------------------------------------------------"
    Write-Output ($resultSet | Sort-Object)
}
finally
{
    Pop-Location
}