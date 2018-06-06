#! /bin/sh

mysql -h terraform-20180518124725528500000001.crdmdddxvfh2.eu-west-1.rds.amazonaws.com -P 3306 -u datavault -p -D datavault \
    -e "DELETE FROM ArchiveStores WHERE storageClass != 'org.datavaultplatform.common.storage.impl.S3Cloud';" \
    -e "UPDATE ArchiveStores SET retrieveEnabled = true;" \
    -e "SELECT * FROM ArchiveStores;" \
