#! /bin/sh

COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME:-rdssdatavault}
export COMPOSE_PROJECT_NAME

WEB_IP_ADDRESS=$(docker inspect --format "{{.NetworkSettings.Networks.${COMPOSE_PROJECT_NAME}_default.IPAddress}}" ${COMPOSE_PROJECT_NAME}_web_1)
docker-compose exec mysql mysql -u datavault -p -D datavault \
    -e "DELETE FROM ArchiveStores WHERE storageClass = 'org.datavaultplatform.common.storage.impl.S3Cloud';" \
    -e "UPDATE ArchiveStores SET storageClass = 'org.datavaultplatform.common.storage.impl.LocalFileSystem', label = 'Default archive store (Local)';" \
    -e "UPDATE Clients SET ipAddress = '${WEB_IP_ADDRESS}';" \
    -e "SELECT * FROM ArchiveStores;" \

docker cp ../src/datavault/docker/tmp/Users/ ${COMPOSE_PROJECT_NAME}_broker_1:/
