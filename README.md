# cicd-template-repo

CI/CD 設定を量産するためのスターターリポジトリです。  

## できること

- `dev` / `prod` 用 GitHub Actions workflow をそのまま利用可能
- Terraform backend（S3）前提の `backend.tf` / `terraform.tfvars` を env ごとに利用可能


## 初回に編集する主な項目:

- workflow: `project_suffix`, `aws_region`, reusable workflow の参照先 (`uses`)
- tfvars: `project`（必要に応じて `account_id`, `aws_region`）
- GitHub Variables / Secrets は不要（workflow 内で固定値を使用）
- state バケットは env ごとに固定値（dev: `h-katabami-cicd-state-237710157750` / prod: `h-katabami-cicd-state-353666332910`）

## 命名統一ルール

- `project_suffix` を 1 箇所変更すると、Lambda 名は `TwilioCustomParts-<project_suffix>` で統一されます。
- Lambda ソース配置先は `lambda/TwilioCustomParts-<project_suffix>/lambda_function.py` に揃えてください。
