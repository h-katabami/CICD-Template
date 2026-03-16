param(
  [Parameter(Mandatory = $true)]
  [string]$TargetRepoPath,

  [Parameter(Mandatory = $true)]
  [string]$ProjectName,

  [Parameter(Mandatory = $true)]
  [string]$AwsRegion,

  [Parameter(Mandatory = $true)]
  [string]$CicdRepoSlug,

  [string]$CicdRepoRef = "main",

  [Parameter(Mandatory = $true)]
  [string]$AwsAccountId
)

$ErrorActionPreference = "Stop"

$TemplateRoot = Split-Path -Parent $PSScriptRoot
$WorkflowTemplateDir = Join-Path $TemplateRoot "templates/github-workflows"
$TerraformTemplateDir = Join-Path $TemplateRoot "templates/terraform-env"

function Write-TemplateFile {
  param(
    [string]$TemplatePath,
    [string]$OutputPath
  )

  $content = Get-Content $TemplatePath -Raw
  $content = $content.Replace("__PROJECT_NAME__", $ProjectName)
  $content = $content.Replace("__AWS_REGION__", $AwsRegion)
  $content = $content.Replace("__CICD_REPO_SLUG__", $CicdRepoSlug)
  $content = $content.Replace("__CICD_REPO_REF__", $CicdRepoRef)
  $content = $content.Replace("__AWS_ACCOUNT_ID__", $AwsAccountId)

  $parent = Split-Path -Parent $OutputPath
  if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  Set-Content -Path $OutputPath -Value $content -Encoding UTF8
}

if (-not (Test-Path $TargetRepoPath)) {
  throw "Target repo path not found: $TargetRepoPath"
}

$targetWorkflows = Join-Path $TargetRepoPath ".github/workflows"
$targetDevTfDir = Join-Path $TargetRepoPath "infra/terraform/envs/dev"
$targetProdTfDir = Join-Path $TargetRepoPath "infra/terraform/envs/prod"

Write-TemplateFile -TemplatePath (Join-Path $WorkflowTemplateDir "deploy-dev.yml.template") -OutputPath (Join-Path $targetWorkflows "deploy-dev.yml")
Write-TemplateFile -TemplatePath (Join-Path $WorkflowTemplateDir "deploy-prod.yml.template") -OutputPath (Join-Path $targetWorkflows "deploy-prod.yml")

Write-TemplateFile -TemplatePath (Join-Path $TerraformTemplateDir "backend.tf.template") -OutputPath (Join-Path $targetDevTfDir "backend.tf")
Write-TemplateFile -TemplatePath (Join-Path $TerraformTemplateDir "backend.tf.template") -OutputPath (Join-Path $targetProdTfDir "backend.tf")

$prodTfvarsPath = Join-Path $targetProdTfDir "terraform.tfvars"
if (-not (Test-Path $prodTfvarsPath)) {
  Write-TemplateFile -TemplatePath (Join-Path $TerraformTemplateDir "terraform.tfvars.prod.template") -OutputPath $prodTfvarsPath
}

Write-Host "Generated CI/CD templates for: $TargetRepoPath"
Write-Host "Next: set repository variable TF_STATE_BUCKET and secrets AWS_ROLE_ARN_DEV / AWS_ROLE_ARN_PROD"
Write-Host "Caller workflows reference reusable workflow: $CicdRepoSlug@$CicdRepoRef"
