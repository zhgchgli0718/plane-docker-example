# 備份 Plane 資料
# Author: zhgchgli (https://zhgchg.li)

##### 執行方式
# ./plane-backup.sh [備份到目標資料夾路徑] [Plane 的 Docker 專案名稱] [Plane 備份檔案最大保留數量，超過刪除最舊的備份]
# e.g. ./plane-backup.sh /backup/plane plane-app 14
###### 設定

# 備份到目標資料夾
backup_dir=${1:-.}

# Plane 的 Docker 專案名稱
docker_project_name=${2:-"plane-app"}

# Plane 備份檔案最大保留數量，超過刪除最舊的備份
keep_count=${3:-7}

######

# 檢查目錄是否存在
if [ ! -d "$backup_dir" ]; then
  echo "備份失敗，目錄不存在：$backup_dir"
  exit;
fi

# Remove oldest
count=$(find "$backup_dir" -mindepth 1 -type d | wc -l)

while [ "$count" -ge $keep_count ]; do
    oldest_dir=$(find "$backup_dir" -mindepth 1 -maxdepth 1 -type d | while read dir; do
        # 使用 stat 命令獲取修改時間
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS 系統
            echo "$(stat -f %m "$dir") $dir"
        else
            # Linux 系統
            echo "$(stat -c %Y "$dir") $dir"
        fi
    done | sort -n | head -n 1 | cut -d ' ' -f 2-)
    
    echo "Remove oldest backup: $oldest_dir"
    rm -rf "$oldest_dir"

    count=$(find "$backup_dir" -mindepth 1 -type d | wc -l)
done
#

# Backup new
date_dir=$(date "+%Y_%m_%d_%H_%M_%S")
target_dir="$backup_dir/$date_dir"

mkdir -p "$target_dir"

echo "Backuping to: $target_dir"

# Plane's Postgresql .SQL dump
docker exec -i $docker_project_name-plane-db-1 pg_dump --dbname=postgresql://plane:plane@plane-db/plane -c > $target_dir/dump.sql

# Plane's redis
docker run --rm -v $docker_project_name-redis-1:/volume -v $target_dir:/backup ubuntu tar cvf /backup/plane-app_redis.tar /volume > /dev/null 2>&1

# Plane's uploaded files
docker run --rm -v ${docker_project_name}_uploads:/volume -v $target_dir:/backup ubuntu tar cvf /backup/plane-app_uploads.tar /volume > /dev/null 2>&1

echo "Backup up Success!"