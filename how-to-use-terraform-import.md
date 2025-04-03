# Terraformのimportブロックを使ったリソースインポート手順

1. インポート設定の作成
    - `import.tf`ファイルを作成
    - インポート対象のリソースとIDを指定
      - リソース名は、たとえばECRなら https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository#import から

2. 設定の自動生成
   - `terraform plan -generate-config-out=generated.tf`を実行
   - リソースの設定が自動生成される

3. 設定の整理
   - 生成された設定を`main.tf`に移動
   - `generated.tf`は削除

4. インポートの実行
   - `terraform apply`を実行
   - インポートが完了する

5. インポート設定の削除
   - インポートが完了したら`import.tf`は削除可能
