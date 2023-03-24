# Terraformで作成する構成
<img width="600" alt="terraform.jpg" src="./terraform.jpg">

Terraformを使って、GitHubのレポジトリと、AWSでのRoute53のドメインとSNSのトピック、
Amplifyのアプリを作成し、残りのリソースはAmplifyにて作成します。

tfvarsファイルを作成して以下の変数を指定する必要があります。
- github_token   =  GitHubのトークン
- github_owner   =  GitHubのユーザー名