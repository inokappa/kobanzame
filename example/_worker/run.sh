#!/usr/bin/env bash

for i in `seq 0 ${1}`
do
  echo "$(date '+%Y-%m-%d %H:%M:%S') $i 回目の処理です..."
  echo "----------------------------------------------------------"
  stress --cpu 2 --vm 2 --vm-bytes 128M --timeout 60s
  echo "----------------------------------------------------------"
  echo "$(date '+%Y-%m-%d %H:%M:%S') $i 回目の処理が完了しました."
  echo ""
  sleep 1
done
echo "完"
exit 1
