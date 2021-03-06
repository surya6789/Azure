# Bumps the version of all of the tasks that are technically modified when packaging-common is changed.
# Please validate the updated versions to confirm that nothing went horribly wrong.
Param(
[parameter(Mandatory=$true)]
# The current sprint, find at https://whatsprintis.it/
[int] $currentSprint,
# The path to the Tasks folder
[parameter()]
[string] $taskRoot = (Join-Path $PSScriptRoot "..\..")
)

"DotNetCoreCLIV2","DownloadPackageV0","DownloadPackageV1","MavenV2","MavenV3","NpmV1","NpmAuthenticateV0","NuGetV0","NuGetCommandV2","NuGetPublisherV0","NuGetToolInstallerV0","NuGetToolInstallerV1","PipAuthenticateV0","TwineAuthenticateV0","UniversalPackagesV0" | % {
    $taskLocation = Join-Path "$taskRoot/$_" "task.json"
    $taskContent = Get-Content $taskLocation 
    $task = $taskContent | ConvertFrom-Json
    $v = $task.version
    $newPatch = 0
    if ($v.Minor -eq $currentSprint) {
        $newPatch = $v.Patch + 1
    }
    Write-Output "${_}: $($v.Major).$($v.Minor).$($v.Patch) to $($v.Major).$currentSprint.$newPatch"
    # Doing an awkward string replace to not interfere with any custom task.json formatting
    $versionMatch = $taskContent | Select-String '"version":'
    $versionLine = $versionMatch.LineNumber
    $taskContent[$versionLine+1] = $taskContent[$versionLine+1].Replace(" $($v.Minor),", " $currentSprint,")
    $taskContent[$versionLine+2] = $taskContent[$versionLine+2].Replace(" $($v.Patch)", " $newPatch")
    $taskContent | Set-Content $taskLocation
}