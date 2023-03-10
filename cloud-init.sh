#cloud-config
# have cloud init map a log to the specified folder
output: { all : '| tee -a /var/log/cloud-init-output.log' }

bootcmd:
  - ln -sf bash /bin/sh

runcmd:
#install aws cli to attach ebs
- sudo apt install awscli -y
#get the instance id from within the instance
- instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

#get the volume id of ebs storage
- volume_id=vol-007a523ac0c46a56a;

#attach volume to instance
- aws ec2 attach-volume --volume-id `echo $volume_id` --instance-id `echo $instance_id` --device /dev/sdf
- sudo mkfs -t xfs /dev/sdf
- sudo mkdir /data
- sudo mount /dev/sdf /data


#get security credentials for authorisiation
# http://169.254.169.254/latest/meta-data/identity-credentials/ec2/security-credentials/ec2-instance