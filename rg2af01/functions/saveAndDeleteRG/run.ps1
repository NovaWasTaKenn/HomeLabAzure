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
$SecurePassword = ConvertTo-SecureString -String "SiG8Q~o-YA5X.MW4hBpBbGOAQsfmgHLslEi6VbX2" -AsPlainText -Force
$TenantId = '422ebf9d-65c2-4e22-84b8-6fe15a8b7444'
$ApplicationId = '09ddf5c5-57f5-4c82-86bb-13faf56cd3c6'
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
Get-AzContext


foreach($resourceGroupName in $resourceGroupList){

    $armFilePath = "D:\home\site\wwwroot\saveAndDeleteRG\$($resourceGroupName).json"
    $repoPath = "D:\home\site\wwwroot\saveAndDeleteRG\repo"

    Write-Host "in foreach"

    # Get the resource group
    Export-AzResourceGroup -ResourceGroupName $resourceGroupName -Path $armFilePath -Force

    if(Test-Path $repoPath){

        cd $repoPath
        git init
        git remote add origin $gitRepoUrl
        git pull
        git checkout main -f
        git branch --set-upstream-to origin/main

    }
    else{
        git clone -b main --single-branch $gitRepoUrl $repoPath
    }

    #$bicepFilePath = ".\backup\$($resourceGroupName).json"

    # Move the Bicep file to the local repository
    Move-Item $armFilePath -Destination $repoPath
s
    # Change to the Git repository directory
    Set-Location -Path $repoPath

    git -c credential.helper="" config credential.helper

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
