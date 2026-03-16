# cicd-template-repo

CI/CD 設定を量産するためのテンプレートリポジトリです。  
このフォルダはローカル実装用で、GitHub へ発行せずに利用できます。

## できること

- `cicd-repo` の reusable workflow を呼び出す `dev` / `prod` 用 GitHub Actions を生成
- Terraform backend（S3）前提の `backend.tf` / `terraform.tfvars` 雛形を生成

## 使い方

PowerShell で以下を実行します。

```powershell
./scripts/new-cicd-project.ps1 `
  -TargetRepoPath "C:/path/to/your-repo" `
  -ProjectName "Kawagoe-City" `
  -AwsRegion "ap-northeast-1" `
  -CicdRepoSlug "your-org/cicd-repo" `
  -CicdRepoRef "main" `
  -AwsAccountId "123456789012"
```

生成物:

- `<target>/.github/workflows/deploy-dev.yml`
- `<target>/.github/workflows/deploy-prod.yml`
- `<target>/infra/terraform/envs/dev/backend.tf`
- `<target>/infra/terraform/envs/prod/backend.tf`
- `<target>/infra/terraform/envs/prod/terraform.tfvars`（未存在時のみ）

## 追加で設定が必要なもの

- `cicd-repo` を GitHub 上で公開し、Actions から参照可能にする
- GitHub Repository Variable: `TF_STATE_BUCKET`
- GitHub Secret: `AWS_ROLE_ARN_DEV`, `AWS_ROLE_ARN_PROD`

## Kawagoe へ適用するときに必要な値

- `CicdRepoSlug`: GitHub 上の `owner/repo`。例: `your-org/CICD-Repository`
- `CicdRepoRef`: reusable workflow を参照するブランチまたはタグ。通常は `main`
