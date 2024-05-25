# 恢復 Plane 備份資料
# Author: zhgchgli (https://zhgchg.li)

##### 執行方式
# ./plane-restore.sh

# 
inputBackupDir() {
    read -p "欲恢復的 Plane 備份檔案資料夾 (e.g. /backup/plane/2024_05_25_19_14_12): " backup_dir
}
inputBackupDir

if [[ -z $backup_dir ]]; then
    echo "請提供備份資料夾 (e.g. sh /backup/docker/plane/2024_04_09_17_46_39)"
    exit;
fi

inputDockerProjectName() {
    read -p "Plane 的 Docker 專案名稱 (留空使用預設 plane-app): " input_docker_project_name
}
inputDockerProjectName
 
docker_project_name=${input_docker_project_name:-"plane-app"}

confirm() {
    read -p "您確定要執行 Restore Plane.so 資料? [y/N] " response
    
    # Check the response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

if ! confirm; then
    echo "Action cancelled."
    exit
fi

# 恢復

echo "Restoring..."

docker cp $backup_dir/dump.sql $docker_project_name-plane-db-1:/dump.sql && docker exec -i $docker_project_name-plane-db-1 psql postgresql://plane:plane@plane-db/plane -f /dump.sql

# 恢復 Redis
docker run --rm -v ${docker_project_name}-redis-1:/volume -v $backup_dir:/backup alpine tar xf /backup/plane-app_redis.tar --strip-component=1 -C /volume

# 恢復上傳的檔案
docker run --rm -v ${docker_project_name}_uploads:/volume -v $backup_dir:/backup alpine tar xf /backup/plane-app_uploads.tar --strip-component=1 -C /volume

echo "Restore Success!"