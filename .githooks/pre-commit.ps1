write-output "This is a pre-commit powershell call"
write-output "======================================="

Import-Module -Name PSScriptAnalyzer

$changes = git diff –name-only
$output = @()

foreach ($change in $changes)
{
    write-output "Running ScriptAnalyzer against: $change"
    $winPath = $change.replace("/", "\")
    $winPath = ".\$winPath"
    $out = Invoke-ScriptAnalyzer -Path $winPath
    $output += $out
}

write-output "======================================="

if ($output.Count -ne 0)
{
    Write-Output "Basic scripting errors were found in updated scripts. fix or use git commit –no-verify"
    $output.Message
    exit 1
}