
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

# attach igw to the vpc

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

