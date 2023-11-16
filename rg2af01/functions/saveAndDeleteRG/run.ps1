using namespace System.Net

#{
#    "ResourceGroupListStr":["RG1"],
#    "GitRepoUrl":"https://github.com/NovaWasTaKenn/HomeLabAzure.git"
#}

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Information "RG list $($Request.Body.ResourceGroupListStr)"

# Define the resource group and Bicep file paths 
$resourceGroupList = $Request.Body.ResourceGroupListStr
#$gitRepoUrl = "https://github.com/NovaWasTaKenn/HomeLabAzure.git"

$gitRepoUrl = $Request.Body.GitRepoUrl

# Authenticate using Managed Identity (Assuming Managed Identity is enabled for the Function App)
Connect-AzAccount -Identity


foreach($resourceGroupName in $resourceGroupList){

    $armFilePath = "D:\home\site\wwwroot\saveAndDeleteRG\$($resourceGroupName).json"
    $repoPath = "D:\home\site\wwwroot\saveAndDeleteRG\repo"

    #$bicepFilePath = ".\backup\$($resourceGroupName).json"

    # Get the resource group
    Export-AzResourceGroup -ResourceGroupName $resourceGroupName -Path $armFilePath

    # Clone the Git repository
    git clone -b main --single-branch $gitRepoUrl $repoPath

    # Move the Bicep file to the local repository
    Move-Item $armFilePath -Destination $repoPath 

    # Change to the Git repository directory
    Set-Location -Path $repoPath

    git checkout main

    # Add the arm file to the Git staging area
    git add .

}

# Commit the changes
git commit -m "Adding resource group arm file"

# Push the changes to the remote repository
git push

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
})
