$output = azd env get-values

foreach ($line in $output) {
    if (!($line)){
      break
    }
      $name = $line.Split('=')[0]
      $value = $line.Split('=')[1].Trim('"')
      Set-Item -Path "env:\$name" -Value $value
}

Write-Host "Environment variables set."

$tools = @("az", "swa", "func")

foreach ($tool in $tools) {
  if (!(Get-Command $tool -ErrorAction SilentlyContinue)) {
    Write-Host "Error: $tool command line tool is not available, check pre-requisites in README.md"
    exit 1
  }
}

Write-Host $env:AZURE_RESOURCE_GROUP
# az account set --subscription $env:AZURE_SUBSCRIPTION_ID
Write-Host $env:AZURE_SUBSCRIPTION_ID
Write-Host $env:AZURE_STATICWEBSITE_NAME
cd ./app/frontend

$SWA_DEPLOYMENT_TOKEN = az staticwebapp secrets list --name $env:AZURE_STATICWEBSITE_NAME --resource-group rg-env0804 --query "properties.apiKey" --output tsv
Write-Host $SWA_DEPLOYMENT_TOKEN
if ($SWA_DEPLOYMENT_TOKEN -ne "") {
  swa deploy --env production --deployment-token $SWA_DEPLOYMENT_TOKEN
} else {
  Write-Host "SWA_DEPLOYMENT_TOKEN is empty, not deployoing froentend, check if the static website is created in Azure portal."
}

cd ../backend
func azure functionapp publish $env:AZURE_FUNCTION_NAME --python

Write-Host "Deployment completed."
cd ../..