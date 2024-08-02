## 概要
TerraformとAnsibleを用いたMinecraftのデプロイ自動化です  
さくらのクラウド上に展開します

## 前提条件
さくらのクラウド上で環境構築が可能な状態であること  
※ 構築時に必要となるさくらのクラウドのトークン、シークレットキーは公式を参照の上取得ください

## IaaS環境
- さくらのクラウド
- AWSやGoogleCloudなども対応予定(円安中はちょっと無理かも？)

## 作業の流れ
以下の順番にて設定を行って下さい
1. Docker上に設定環境の構築
2. Terraformによるインフラ設定
3. Ansibleによるアプリケーション設定

## Docker上に設定環境の構築
ルートディレクトリにて設定環境用コンテナ(infra-micra)をデプロイします
```
docker compose -f docker-compose.yml up -d
```
設定環境用コンテナ起動後は以下でコンテナ内に入ります
```
docker exec -it infra-micra bash
```
以上の操作にて、設定環境用コンテナに入り、以下の手続きはすべて設定環境用コンテナから行います

## SSH証明書の作成
サーバ接続用SSH証明書を作成し展開用ディレクトリに設置します
```
ssh-keygen -t rsa -b 4096
mv /root/.ssh/id_rsa* /path/to/ssh
```
## 環境変数の設定
```
export TF_VAR_sakuracloud_token=<さくらのクラウド トークン>
export TF_VAR_sakuracloud_secret=<さくらのクラウド シークレットキー>
export TF_VAR_sakura_zone=is1b # 石狩第二を選択
export TF_VAR_ssh_public_key_path=./ssh/id_rsa.pub
export TF_VAR_ssh_allow_ipaddr=<作業用端末のグローバルIPアドレス>
```
作業用端末のグローバルIPアドレスは、curl inet-ip.info などで取得してください

## Terraformによるインフラ設定
以下の操作にてIaaS上にサーバをデプロイします
```
cd terraform-sakuracloud/
terraform init
terraform apply
```

尚、リソース設定は以下で行います
```
vi terraform-sakuracloud/variables.tf
```
| 項目 | 内容|
| -- | -- |
| os_type | OS |
| core | コア数 |
| memory | メモリー容量 |
| plan | ディスクプラン |
| size | ディスク容量 |
| password | デフォルトユーザのパスワード |

__passwordは必ず初期値から変更してお使いください__  
各項目の設定についてはリファレンスを参考にしてください  
https://docs.usacloud.jp/terraform/  


## Ansibleによるアプリケーション設定

以下の操作にてデプロイしたサーバ上にアプリケーション設定を行います
```
cd ansible/
ansible-playbook -i ../terraform_sakuracloud/minecraft_server.ini -u ubuntu --private-key=../terraform_sakuracloud/ssh/id_rsa -K minecraft.yml
```

## Minecraftの構成について
構成情報はymlファイルを参照ください
```
vi ansible/docker-compose.yml
```
構成変更をしたい場合は、Docker Minecraftのリファレンスを参考にしてください   
https://docker-minecraft-server.readthedocs.io/en/latest/variables/

### 構成変更サンプル
バージョンを最新から1.14へ変更する
```
vi ansible/docker-compose.yml

VERSION: ""LATEST"" -> "1.14"

# 1.14付近はCVE-2021-44228(Log4j任意コード実行)の影響を受けるためローテーションは無効化する
ENABLE_ROLLING_LOGS: "TRUE" -> "FALSE"

# vanilla, vanilla-backupsそれぞれのフォルダをバージョン毎に管理する
volumes:
  ./vanilla:/data -> ./vanilla114:/data
```

## Minecraftの環境設定
任意のPlayerに管理者権限を付与するには以下を実施してください
```
# RCON クライアント起動
docker exec -i mc_vanilla rcon-cli

# オペレータ権限を付与
op username

# [CTL]+[C]でRCONを抜ける
```
