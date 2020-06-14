#!/usr/bin/env bash

function continue?() {
  if [ "${OPTION_FLAG}" != "batch" ];then
    while true; do
      read -p 'Do you want to continue processing? [Y/n]' Answer
      case $Answer in
        '' | [Yy]* )
          echo "Continue processing..."
          break
          ;;
        [Nn]* )
          echo "Interrupted."
          exit 0
          ;;
        * )
          echo Please answer YES or NO.
      esac
    done;
  else
    echo "Skip interactive."
  fi
}

case ${1} in
  "dev" )
    MESSAGE="Run Task for \e[37;44;1m $1 \e[m Environment."
    FARGATE_CLUSTER=""
    FARGATE_TASK_DEFINITION=""
    FARGATE_SUBNETS=""
    FARGATE_SECURITY_GROUP=""
    COLOR_CODE="\e[36m"
    ;;
  *)
    echo "Please input 'dev' or 'prd'."
    exit 1
    ;;
esac

printf "==================================================================\n"
printf "${MESSAGE} Execute the command as follows.\n"
printf "==================================================================\n"
printf "===> run-task.json are as follows.\n"
printf "${COLOR_CODE}$(cat run-task.json)\e[m\n"
printf "===> Execute the command as follows.\n"
printf "${COLOR_CODE}aws ecs run-task\n  --region ap-northeast-1\n  --cluster "${FARGATE_CLUSTER}"\n  --task-definition "${FARGATE_TASK_DEFINITION}"\n  --overrides file://"$(pwd)"/config/run-task.json\n  --launch-type FARGATE\n  --network-configuration \"awsvpcConfiguration={subnets=[${FARGATE_SUBNETS}],securityGroups=[${FARGATE_SECURITY_GROUP}],assignPublicIp=ENABLED}\"\e[m\n"
printf "==================================================================\n"

continue?

aws ecs run-task \
  --region ap-northeast-1 \
  --cluster "${FARGATE_CLUSTER}" \
  --task-definition "${FARGATE_TASK_DEFINITION}" \
  --overrides file://"$(pwd)"/run-task.json \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[${FARGATE_SUBNETS}],securityGroups=[${FARGATE_SECURITY_GROUP}],assignPublicIp=ENABLED}"
