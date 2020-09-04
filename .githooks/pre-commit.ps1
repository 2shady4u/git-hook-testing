write-output "This is a pre-commit powershell call"
write-output "======================================="

# Set path correctly.
$originaldir = Get-Location
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$dir = Split-Path -Path $dir -Parent

Write-host "My directory is $dir"
Set-Location -Path $dir

$exfiles = @('README.md', 'pre-commit', 'pre-commit.ps1')
$exdirectories = @('.githooks')

$files = Get-ChildItem -Path $dir -Recurse -Name -File
$directories = Get-ChildItem -Path $dir -Recurse -Name -Directory
$matchstring = '^[a-z][_[a-z]+]?$'
$output = 0

foreach ($name in $files)
{
    if ($exfiles -contains (Get-Item $name ).Name){
        continue
    }

    $name = (Get-Item $name ).BaseName
    $snakematch = $name -cmatch $matchstring
    if ($snakematch) {
        write-output "Snake matched: $name"
    } else {
        write-output "Does not obey snake_match: $name"
        $output += 1
    }
}

foreach ($name in $directories)
{
    if ($exdirectories -contains $name){
        continue
    }

    $name = (Get-Item $name ).BaseName
    $snakematch = $name -cmatch $matchstring
    if ($snakematch) {
        write-output "Snake matched: $name"
    } else {
        write-output "Does not obey snake_match: $name"
        $output += 1
    }
}

write-output "======================================="

# Go back to the root folder.
Set-Location -Path $originaldir

if ($output -ne 0)
{
    Write-Output "Naming conventions are not respected! Use snake_case for all file- and folder-names!"
    $output.Message
    exit 1
} else {
    Write-Output "All naming conventions seem to be in order... you win this one..."
    exit 0
}
