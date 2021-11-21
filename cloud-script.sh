
#----------------------------------- Configuration -----------------------------------#
# cloud-script.sh
# use the following profile for all commands
export AWS_PROFILE=frauholle;

# configure the profile
aws configure set region eu-central-1 --profile $AWS_PROFILE
aws configure set output json --profile $AWS_PROFILE

#----------------------------------- VPC + Subnets -----------------------------------#
# create VPC
# --query traverses the returned JSON and returns filtered output as text. The VpcId is returned and stored in VPC_ID
# --profile takes a valid local profile for credentials.
# --tag-specifications assigns tags to resources
VPC_ID=$(aws ec2 create-vpc \
    --cidr-block 192.168.0.0/24 \
    --query Vpc.VpcId \
    --output text \
    --tag-specifications 'ResourceType=vpc, Tags=[{Key=Name, Value=cli-vpc}]')

# create subnets
# subnets are created within the vpc with VPC_ID
# subnets have 2^6-5=59 addreses, 4 possible SN within /26 
 SN_DMZ_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.0/26\
    --query Subnet.SubnetId \
    --output text \
    --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name, Value=cli-sn-dmz}]')

SN_APP_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.64/26\
    --query Subnet.SubnetId \
    --output text \
    --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name, Value=cli-sn-app}]')

SN_DATA_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.128/26\
    --query Subnet.SubnetId \
    --output text \
    --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name, Value=cli-sn-data}]')

#----------------------------------- Internetgateway Gateway -----------------------------------#
# make sn-dmz public
# create an internet gateway
# of SNs are routed to a IGW, they are called public

IGW_ID=$(aws ec2 create-internet-gateway \
    --tag-specifications 'ResourceType=internet-gateway, Tags=[{Key=Name, Value=cli-igw}]'\
    --query InternetGateway.InternetGatewayId \
    --output text)

# attach Internet Gateway to the vpc

aws ec2 attach-internet-gateway \
--vpc-id $VPC_ID \
--internet-gateway-id $IGW_ID

#----------------------------------- NAT Gateway -----------------------------------#
# allocate an elastic IP for nat-gateway and store the allocation-id
IP_ALL_ID_NAT=$(aws ec2 allocate-address \
    --tag-specifications 'ResourceType=elastic-ip, Tags=[{Key=Name, Value=cli-eip-nat}]'\
    --query AllocationId \
    --output text)

# create a nat gateway for outbound traffic
NAT_ID=$(aws ec2 create-nat-gateway \
    --subnet-id $SN_DMZ_ID \
    --allocation-id $IP_ALL_ID_NAT\
    --tag-specifications 'ResourceType=natgateway, Tags=[{Key=Name, Value=cli-natgateway}]'\
    --query 'NatGateway.NatGatewayId'\
    --output text)
echo $NAT_ID

# delete the nat, returns the id of the deleted nat
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_ID
# release the disassociated elastic ip
aws ec2 release-address $IP_ALL_ID_NAT

#----------------------------------- create APP Routetable  -----------------------------------#

# create a route table; route tables provide paths within the vpc, whereas security group filter traffic along existing paths
# main route table for traffic within vpc
RTB_APP=$(aws ec2 create-route-table\
    --vpc-id $VPC_ID \
    --tag-specifications 'ResourceType=route-table, Tags=[{Key=Name, Value=cli-rtb-app}]'\
    --query RouteTable.RouteTableId\
    --output text)

# create main route table to connect subnets to the internet via nat
aws ec2 create-route \
--route-table-id $RTB_APP \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $NAT_ID

# attach table to specific subnet
aws ec2 associate-route-table --subnet-id $SN_APP_ID --route-table-id $RTB_APP

#verify that route table exists
aws ec2 describe-route-tables --route-table-id $RTB_APP

#----------------------------------- create DMZ Routetable  -----------------------------------#

# custom route table for traffic in public subnet sn-dmz
RTB_DMZ=$(aws ec2 create-route-table \
--vpc-id $VPC_ID \
--tag-specifications 'ResourceType=route-table, Tags=[{Key=Name, Value=cli-rtb-dmz}]' \
--query RouteTable.RouteTableId \
--output text)

#create a route for the custom routetable to point all traffic to the internet gateway
aws ec2 create-route \
--route-table-id $RTB_DMZ \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $IGW_ID

# attach table to specific subnet
aws ec2 associate-route-table --subnet-id $SN_DMZ_ID --route-table-id $RTB_DMZ

#verify that route table exists
aws ec2 describe-route-tables --route-table-id $RTB_DMZ

#----------------------------------- create DATA Routetable  -----------------------------------#

# custom route table for traffic in public subnet sn-data
RTB_DATA=$(aws ec2 create-route-table \
--vpc-id $VPC_ID \
--tag-specifications 'ResourceType=route-table, Tags=[{Key=Name, Value=cli-rtb-data}]' \
--query RouteTable.RouteTableId \
--output text)

#create a route for the custom routetable to point all traffic to the nat gateway
# we could just use the app route table or
# does the data sn need access to the internet?
aws ec2 create-route \
--route-table-id $RTB_DATA \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $NAT_ID

# attach table to specific subnet
aws ec2 associate-route-table --subnet-id $SN_DATA_ID --route-table-id $RTB_DATA

#verify that route table exists
aws ec2 describe-route-tables --route-table-id $RTB_DATA

#----------------------------------- create Security Group  -----------------------------------#
# security groups control inbound and outbound traffic for instances, whereas network ACLs control in and outbound traffic for subnets.

#----------------------------------- save my ip into a variable
MY_IP=$(curl https://checkip.amazonaws.com)

#create a new security-group DMZ
DMZ_SG=$(aws ec2 create-security-group \
    --group-name dmz-sg \
    --description "demilitarized zone"\
    --vpc-id $VPC_ID \
    --query GroupId \
    --output text \
    --tag-specifications 'ResourceType=security-group, Tags=[{Key=GroupName, Value=dmz-sg}]')

#-----------------------------------  Allow my-ip to connect DMZ-SG via http und ssh
aws ec2 authorize-security-group-ingress \
--group-id $DMZ_SG \
--protocol tcp \
--port 22 \
--cidr $MY_IP/32

aws ec2 authorize-security-group-ingress \
--group-id $DMZ_SG \
--protocol tcp \
--port 80 \
--cidr $MY_IP/32

#----------------------------------- create a new security-group APP and allow DMZ-SG to reach it via http and ssh
APP_SG=$(aws ec2 create-security-group \
    --group-name app-sg \
    --description "APP SG"\
    --vpc-id $SN_APP_ID \
    --query GroupId \
    --output text \
    --tag-specifications 'ResourceType=security-group, Tags=[{Key=GroupName, Value=app-sg}]')

# ----------------------------------- Allow DMZ-SG to connect APP-SG via http and ssh
aws ec2 authorize-security-group-ingress \
--group-id $APP_SG \
--protocol tcp \
--port 22 \
--source-group $DMZ_SG
#and the sec rule
aws ec2 authorize-security-group-ingress \
--group-id $APP_SG \
--protocol tcp \
--port 80 \
--source-group $DMZ_SG



#----------------------------------- create a new security-group DATA and allow APP-SG to reach it via SQL
DATA_SG=$(aws ec2 create-security-group \
    --group-name data-sg \
    --description "DATA SG" \
    --vpc-id $SN_DATA_ID \
    --query GroupId \
    --output text \
    --tag-specifications 'ResourceType=security-group, Tags=[{Key=GroupName, Value=data-sg}]')

# ----------------------------------- Allow APP-SG to connect DATA-SG via SQL
aws ec2 authorize-security-group-ingress \
--group-id $DATA_SG \
--protocol tcp \
--port 1433 \
--source-group $APP_SG



#---------------------------------- Erstelle einen ssh schlüssel
aws ec2 create-key-pair --key-name App_KeyPair --query 'KeyMaterial' --output text > App_KeyPair.pem

#----------------------------------- launch an EC2 Instance into SN-DMZ as well as DMZ-sg
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id ami-0d5075a2643fdf738 \
    --count 1 \
    --instance-type t2.micro \
    --key-name "App_KeyPair" \
    --security-group-ids $APP_SG \
    --subnet-id $SN_APP_ID \
    --user-data file://cloud-init.sh \
    --tag-specifications 'ResourceType=instance, Tags=[{Key=InstanceName, Value=dmz-instance}]' \
    --query 'Instances[0].InstanceId' \
    --output text \
    )

#----------------------------------- um die Instance zu löschnen
# $ aws ec2 terminate-instances --instance-ids $INSTANCE_ID

#----------------------------------- launch an EC2 Instance into SN-DMZ as well as DMZ-sg

ws ec2 create-key-pair --key-name bastion-key-pair --query 'KeyMaterial' --output text > bastion-key-pair.pem

BASTION_EC2_ID=$(aws ec2 run-instances \
    --image-id ami-0bd99ef9eccfee250 \
    --count 1 \
    --instance-type t2.micro \
    --key-name "bastion-key-pair" \
    --security-group-ids $DMZ_SG \
    --subnet-id $SN_DMZ_ID \
    --tag-specifications 'ResourceType=instance, Tags=[{Key=Name, Value=cli-bastion-instance}]' \
    --query 'Instances[0].InstanceId' \
    --output text \
)






















aws ec2 describe-instances --query 'Reservations[*].Instances[*]'

IP_LB=

IP_BASTION=


# associate IP and store the association-id
IP_ASS_ID_NAT =$(aws ec2 allocate-address \
    --query AssociationId \
    --output text)

# disassociate IP
aws ec2 disassociate-address --association-id $IP_ASS_ID_NAT

# release IP
aws ec2 release-address --allocation-id $IP_ALL_ID_NAT

#----------------------------------- Utilities -----------------------------------#
# list all vpcs unfiltered
aws ec2 describe-vpcs --query Vpcs.[0]

# list all subnets of the specific vpc
aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].{ID:SubnetId,CIDR:CidrBlock}"

# Man könnte auch mit describe-x Dinge anzeigen und sich die IP holen indem man nach einem bekannten Tag filtert anstatt alle IDs in Variablen zu speichern.



# ----------------------------------- Assign EIP to instance -----------------------------------#

IP_ALL_ID_INSTANCE_1=$(aws ec2 allocate-address \
    --tag-specifications 'ResourceType=elastic-ip, Tags=[{Key=Name, Value=cli-eip-instance-1}]'\
    --query AllocationId \
    --output text)

# associate IP and store the association-id
IP_ASS_ID_INSTANCE_1=$(aws ec2 associate-address \
    --instance-id $INSTANCE_ID_1 \
    --allocation-id $IP_ALL_ID_INSTANCE_1 \
    --query AssociationId \
    --output text)

# disassociate IP
aws ec2 disassociate-address --association-id $IP_ASS_ID_INSTANCE_1

# release IP
aws ec2 release-address --allocation-id $IP_ALL_ID_INSTANCE_1









# ----------------------------------- allocate an elastic IP for Load Balancer and store the allocation-id
IP_ALL_ID_LB=$(aws ec2 allocate-address \
    --tag-specifications 'ResourceType=elastic-ip, Tags=[{Key=Name, Value=cli-eip-LB}]' \
    --query AllocationId \
    --output text)

# ----------------------------------- Create a Loade Balancer -----------------------------------#
LOAD_BALANCER_ARN=$(aws elbv2 create-load-balancer --name network-LB --type network --subnet-mappings SubnetId=$SN_DMZ_ID,AllocationId=$IP_ALL_ID_LB --query 'LoadBalancers[0].LoadBalancerArn'  --output text)

TARGETGROUP_ARN=$(aws elbv2 create-target-group --name my-targets --protocol TCP --port 80 --vpc-id $VPC_ID --query 'TargetGroups[0].TargetGroupArn'  --output text)

aws elbv2 register-targets --target-group-arn $TARGETGROUP_ARN --targets Id=$INSTANCE_ID

aws elbv2 create-listener --load-balancer-arn $LOAD_BALANCER_ARN --protocol TCP --port 80  --default-actions Type=forward,TargetGroupArn=$TARGETGROUP_ARN

