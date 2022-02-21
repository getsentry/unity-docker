# Given a version prefix, e.g. "2021.", returns the latest available version and its changeset, e.g. 2021.2.12f1/48b1aa000234
param (
    [string] $prefix = ""
)

$ProgressPreference = 'SilentlyContinue'
$page = Invoke-WebRequest -UseBasicParsing -Uri 'https://unity3d.com/get-unity/download/archive'

$hubPrefix = "unityhub://"
$items = $page.Links.Href | Select-String -Pattern $hubPrefix | ForEach-Object { $_.ToString().Substring($hubPrefix.Length) }

if ("$prefix" -ne "") {
    $items = $items | Select-String -Pattern $prefix
}

$items[0].ToString()