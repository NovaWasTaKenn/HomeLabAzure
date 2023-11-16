using namespace System.Net

#{
#    "ResourceGroupListStr":["RG1"],
#    "GitRepoUrl":"https://github.com/NovaWasTaKenn/HomeLabAzure.git"
#}

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Import-Module Bicep

Write-Information "RG list $($Request.Body.ResourceGroupListStr)"

# Define the resource group and Bicep file paths 
$resourceGroupList = $Request.Body.ResourceGroupListStr
#$gitRepoUrl = "https://github.com/NovaWasTaKenn/HomeLabAzure.git"

$gitRepoUrl = $Request.Body.GitRepoUrl

# Authenticate using Managed Identity (Assuming Managed Identity is enabled for the Function App)
Connect-AzAccount -Identity

foreach($resourceGroupName in $resourceGroupList){

    $bicepFilePath = "$($resourceGroupName).bicep"
    $bicepFileDir = "D:\home\site\wwwroot\saveAndDeleteRG\"

    #$bicepFilePath = ".\backup\$($resourceGroupName).bicep"

    # Get the resource group
    $resourceGroup = Get-AzResourceGroup -Name $resourceGroupName

    # Convert the resource group to Bicep and save it to a file
    $resourceGroup | ConvertTo-Bicep -Path $bicepFilePath -OutputDirectory $bicepFileDir

    # Clone the Git repository
    #git clone $gitRepoUrl

    # Move the Bicep file to the local repository
    #Move-Item $bicepFilePath -Destination "LocalGitRepository"
    #Move-Item $bicepFilePath -Destination "LocalGitRepository"


    # Change to the Git repository directory
    #Set-Location -Path "LocalGitRepository"

    # Add the Bicep file to the Git staging area
    #git add .

}

# Commit the changes
#git commit -m "Adding resource group Bicep file"

# Push the changes to the remote repository
#git push

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
})
