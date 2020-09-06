write-output "This is a pre-commit powershell call"
write-output "======================================="

$excluded_files = @('README.md', 'pre-commit', 'pre-commit.ps1')
$excluded_directories = @('.githooks')

# Regular expression for matching snake_case
$regex_snake_case = '^[a-z][_[a-z]+]?$'

# Set path correctly.
$originaldir = Get-Location
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath
$dir = Split-Path -Path $dir -Parent

Write-host "My directory is $dir"
Set-Location -Path $dir

# The output that will contain the eventual pre-commit verdict!
$output = 0

# Get all the staged files...
$command = "git diff --name-only --cached"
$command_output = Invoke-Expression $Command

# Go through all the staged files!
foreach ($name in $command_output)
{
    # Check if the file is excluded or not!
    if ($excluded_files -contains (Get-Item $name ).Name){
        continue
    }

    # Attempt to snake_match the file-name.
    $basename = (Get-Item $name ).BaseName
    $match = $basename -cmatch $regex_snake_case
    if (-Not ($match)) {
        write-output "FAILURE: Staged File does not obey snake_match: '$basename'"
        $output += 1
    }

    # Go through the entire folder path as well...
    $folders = $name.Split('/')
    # Skip the last element since it is the file-name.
    $folders = $folders | Select-Object -SkipLast 1

    foreach ($folder in $folders)
    {
        # Again check if the folder belongs to the excluded list or not...
        if ($excluded_directories -contains $folder){
            continue
        }

        # Attempt to snake_match the file-name.
        $match = $folder -cmatch $regex_snake_case
        if (-Not ($match)) {
            write-output "FAILURE: Staged directory-path does not obey snake_match: '$folder'"
            $output += 1
        }
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
