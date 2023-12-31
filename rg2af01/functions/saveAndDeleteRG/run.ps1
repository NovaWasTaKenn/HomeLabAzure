using namespace System.Net

#{
#    "ResourceGroupListStr":["RG1"],
#    "GitRepoUrl":"https://github.com/NovaWasTaKenn/HomeLabAzure.git"
#}

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Information "RG list $($Request.Body.ResourceGroupListStr)"

git config --global user.email "quentin.le-nestour@outlook.com"
git config --global user.name "NovaWasTakenn"
git config --global url."https://api:$env:GH_TOKEN@github.com/".insteadOf "https://github.com/"
git config --global url."https://ssh:$env:GH_TOKEN@github.com/".insteadOf "ssh://git@github.com/"
git config --global url."https://git:$env:GH_TOKEN@github.com/".insteadOf "git@github.com:"

# Define the resource group and Bicep file paths 
$resourceGroupList = $Request.Body.ResourceGroupListStr
#$gitRepoUrl = "https://github.com/NovaWasTaKenn/HomeLabAzure.git"

$gitRepoUrl = $Request.Body.GitRepoUrl

# Authenticate using Managed Identity (Assuming Managed Identity is enabled for the Function App)
Connect-AzAccount -Identity


foreach($resourceGroupName in $resourceGroupList){

    $armFilePath = "D:\home\site\wwwroot\saveAndDeleteRG\$($resourceGroupName).json"
    $repoPath = "D:\home\site\wwwroot\saveAndDeleteRG\repo"

    if(Test-Path $repoPath){

        Remove-Item -LiteralPath $repoPath -Force -Recurse
        Remove-Item -LiteralPath $repoPath -Force -Recurse

    }


    #$bicepFilePath = ".\backup\$($resourceGroupName).json"

    # Get the resource group
    Export-AzResourceGroup -ResourceGroupName $resourceGroupName -Path $armFilePath

    # Clone the Git repository
    git clone -b main --single-branch $gitRepoUrl $repoPath

    # Move the Bicep file to the local repository
    Move-Item $armFilePath -Destination $repoPath

    # Change to the Git repository directory
    Set-Location -Path $repoPath

    # Add the arm file to the Git staging area
    git add .

}

# Commit the changes
git commit -m "Adding resource group arm file"

# Push the changes to the remote repository
git push

#mawsFnPlaceholder198_f_v4_powershell_7.2_x86@10-30-10-114.(none)
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
})
