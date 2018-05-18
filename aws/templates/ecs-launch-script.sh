Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
Content-Type: text/cloud-boothook; charset="us-ascii"

# Install nfs-utils
cloud-init-per once yum_update yum update -y
cloud-init-per once install_efs_utils yum install -y amazon-efs-utils

# Create efs folder
cloud-init-per once mkdir_efs mkdir -p ${efs_mountpoint}

# Mount efs
cloud-init-per once mount_efs echo -e '${efs_fs_id}:/ ${efs_mountpoint} efs tls,_netdev 0 0' >> /etc/fstab
mount -a -t efs defaults

--==BOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
# Set any ECS agent configuration options
echo "ECS_CLUSTER=${cluster}" >> /etc/ecs/ecs.config

--==BOUNDARY==--
