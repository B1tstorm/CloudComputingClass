# cloud-script.sh
# use the following profile for all commands
export AWS_PROFILE=frauholle;

# configure the profile
aws configure set region eu-central-1 --profile $AWS_PROFILE
aws configure set output json --profile $AWS_PROFILE

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
    --cidr-block 192.168.0.0/26
    --query Subnet.SubnetId \
    --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name, Value=cli-sn-dmz}]')

SN_APP_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.64/26
    --query Subnet.SubnetId \
    --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name, Value=cli-sn-app}]')

SN_DATA_ID=$(aws ec2 create-subnet \
    --vpc-id $VPC_ID \
    --cidr-block 192.168.0.128/26
    --query Subnet.SubnetId \
    --tag-specifications 'ResourceType=subnet, Tags=[{Key=Name, Value=cli-sn-data}]')

# make sn-dmz public
# create an internet gateway
IGW_ID=$(aws ec2 create-internet-gateway \
    --query InternetGateway.InternetGatewayId \
    --output text)

# attach igw to the vpc
aws ec2 attach-internet-gateway \
--vpc-id $VPC_ID \
--internet-gateway-id $IGW_ID

# create a route table; route tables provide paths within the vpc, whereas security group filter traffic along existing paths
# main route table for traffic within vpc
RTB_MAIN =$(aws ec2 create-route-table \
    --vcp-id $VPC_ID \
    --query RouteTable.RouteTableId \
    --output text)

# custom route table for traffic in public subnet sn-dmz
RTB_CUSTOM =$(aws ec2 create-route-table \
--vcp-id $VPC_ID \
--query RouteTable.RouteTableId \
--output text)

#create a route to point all traffic to the internet gateway
aws ec2 create-route \
--route-table-id $RTB_MAIN \
--destination-cidr-block 0.0.0.0/0 \
--gateway-id $IGW_ID

#verify that route table exists
aws ec2 describe-route-tables --route-table-id $RTB_MAIN

#----------------------------------- NAT Gateway -----------------------------------#
# allocate an elastic IP for nat-gateway and store the allocation-id
IP_ALL_ID_NAT =$(aws ec2 allocate-address \
    --tag-specifications 'ResourceType=elastic-ip, Tags=[{Key=Name, Value=cli-eip-nat}]'
    --query AllocationId \
    --output text)

# create a nat gateway for outbound traffic
NAT_ID=$(aws ec2 create-nat-gateway \
    --subnet-id $SN_DMZ_ID \
    --allocation-id $IP_ALL_ID_NAT
    --query 'NatGateway.NatGatwayId'
    --output text
    --tag-specifications 'ResourceType=natgateway, Tags=[{Key=Name, Value=cli-natgateway}]')

# delete the nat, returns the id of the deleted nat
aws ec2 delete-nat-gateway --nat-gateway-id $NAT_ID
# release the disassociated elastic ip
aws ec2 release-address $IP_ALL_ID_NAT


#-----------------------------------  -----------------------------------#


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