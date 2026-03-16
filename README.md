# cicd-template-repo

CI/CD 設定を量産するためのテンプレートリポジトリです。  
このフォルダはローカル実装用で、GitHub へ発行せずに利用できます。

## できること

- `cicd-repo` の reusable workflow を呼び出す `dev` / `prod` 用 GitHub Actions テンプレートを提供
- Terraform backend（S3）前提の `backend.tf` / `terraform.tfvars` テンプレートを提供

## 使い方

このリポジトリは GitHub の `Use this template` で新規リポジトリ作成して利用します。

テンプレートファイル:

- `templates/github-workflows/deploy-dev.yml.template`
- `templates/github-workflows/deploy-prod.yml.template`
- `templates/terraform-env/backend.tf.template`
- `templates/terraform-env/terraform.tfvars.dev.template`
- `templates/terraform-env/terraform.tfvars.prod.template`

`terraform.tfvars` テンプレートの既定値:

- dev: `aws_region = "ap-northeast-1"`, `environment = "dev"`, `account_id = "237710157750"`
- prod: `aws_region = "us-east-1"`, `environment = "prod"`, `account_id = "353666332910"`

## 追加で設定が必要なもの

- `cicd-repo` を GitHub 上で公開し、Actions から参照可能にする
- GitHub Repository Variable: `TF_STATE_BUCKET`
- GitHub Secret: `AWS_ROLE_ARN_DEV`, `AWS_ROLE_ARN_PROD`
