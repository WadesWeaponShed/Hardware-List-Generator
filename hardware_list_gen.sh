printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

total=$(mgmt_cli -r true -d $DOMAIN show gateways-and-servers --format json |jq '.total')
printf "There are $total Gateway and Server Objects\n"

printf "\nGetting Cluster Objects\n"
for I in $(seq 0 500 $total)
do
 mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level full offset $I limit 500 --format json | jq --raw-output '.objects[] | select(.type == "CpmiGatewayCluster") | .name + "," + .type + "," + .hardware + "," + ."ipv4-address" + "," + ."cluster-member-names"[]' >> $DOMAIN-hardware-list.txt
done

printf "\nGetting Standalone Objects\n"
for I in $(seq 0 500 $total)
do
 mgmt_cli -r true -d $DOMAIN show gateways-and-servers details-level full offset $I limit 500 --format json | jq --raw-output '.objects[] | select(.type == "simple-gateway") | .name + "," + .type + "," + .hardware + "," + ."ipv4-address"' >> $DOMAIN-hardware-list.txt
done

sed -i '1s/^/NAME,TYPE,HARDWARE,MGMT_IP,CLUSTER_MEMBER_NAME\n/' $DOMAIN-hardware-list.txt
sed -i 's/CpmiGatewayCluster/Cluster/g' $DOMAIN-hardware-list.txt
sed -i 's/simple-gateway/Standalone/g' $DOMAIN-hardware-list.txt
sed -i 's/CpmiVsClusterNetobj/VS/g' $DOMAIN-hardware-list.txt
printf "\nYour Hardware List is located in $DOMAIN-hardware-list.txt\n"
