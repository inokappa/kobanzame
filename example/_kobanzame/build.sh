#!/usr/bin/env bash

# Docker コマンド対応
if [ -z "${DOCKER_COMMAND}" ];then
  DOCKER_COMMAND="docker"
fi

# 環境変数設定 from コマンドライン引数
SERVICE_NAME=kobanzame-sample/kobanzame
DEPLOY_ENV=$1
OPTION_FLAG=$2

# 引数のチェック
CMDNAME=$(basename $0)
if [ $# -lt 1 -o $# -gt 2 ]; then
  echo "Usage: ${CMDNAME} [dev|prd] [repo|batch]" 1>&2
  exit 1
fi

function cocho() {
  printf "\e[36m$1\e[m\n"
}

function wocho() {
  printf "\e[33m$1\e[m\n"
}

function continue?() {
  if [ "${OPTION_FLAG}" != "batch" ];then
    while true; do
      read -p '処理を継続しますか? [Y/n]' Answer
      case $Answer in
        '' | [Yy]* )
          echo "処理を継続します."
          break
          ;;
        [Nn]* )
          echo "処理を中断します."
          exit 0
          ;;
        * )
          echo Please answer YES or NO.
      esac
    done;
  else
    wocho "Skip interactive."
  fi
}

# awscli, jq がインストールされているかチェックする (インストールされていなければ, exit 1 で終了する)
for cmd in aws jq
do
  which ${cmd} > /dev/null 2>&1
  if [ ! $? -eq 0 ];then
    wocho "Please Install ${cmd}!!"
    exit 1
  fi
done

# 環境変数設定 (疑似 YAML ファイルから読み込む)
if [ -f docker-build-config.yml ];then
  eval $(sed -e 's/:[^:\/\/]/="/g;s/$/"/g;s/ *=/=/g' docker-build-config.yml)
else
  wocho "docker-build-config.yml が読み込めません."
  exit 1
fi

# 第二引数をチェックする (repo であれば, ECR のリポジトリを作成)
if [ "${OPTION_FLAG}" == "repo" ];then
  cocho "ECR リポジトリ ${SERVICE_NAME} を作成します."
  continue?
  aws ecr create-repository --repository-name=${SERVICE_NAME}
  if [ ! $? -eq 0 ];then
    wocho "ECR リポジトリ ${SERVICE_NAME} の作成に失敗しました."
    exit 1
  else
    echo "ECR リポジトリ${SERVICE_NAME} の作成に成功しました."
    exit 0
  fi
fi

# 第一引数の内容をチェックする 
case $DEPLOY_ENV in
  "dev" )
    printf "\e[37;44;1m ${DEPLOY_ENV} \e[m 環境のデプロイを開始します.\n" ;;
  "prd" )
    printf "\e[37;41;1m ${DEPLOY_ENV} \e[m 環境のデプロイを開始します.\n" ;;
  * )
    printf "\e[35m${DEPLOY_ENV}\e[m is not valid deployment target!\n" && exit 1 ;;
esac

echo ""
echo "以下の環境変数が設定されています."
echo "--------------------------------------------------------------------"
IMAGE_NAME=${SERVICE_NAME}
echo IMAGE_NAME=${SERVICE_NAME}
ECR_URI=${ECR_URI}
echo ECR_URI=$(cocho ${ECR_URI})
echo "--------------------------------------------------------------------"
continue?

# ビルド
cocho "Step1. Docker イメージをビルドします."
continue?
${DOCKER_COMMAND} build -t ${IMAGE_NAME}:deployment -f Dockerfile --no-cache=true . 
${DOCKER_COMMAND} tag ${IMAGE_NAME}:deployment ${ECR_URI}/${IMAGE_NAME}:${DEPLOY_ENV}

# ECR にデプロイ
cocho "Step2. Docker イメージを ECR に push します."
continue?
aws ecr get-login-password --region ${REGION} \
  | docker login --username AWS --password-stdin ${ECR_URI}
${DOCKER_COMMAND} push ${ECR_URI}/${IMAGE_NAME}:${DEPLOY_ENV}
