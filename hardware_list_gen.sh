printf "\nWhat is the IP address or Name of the Domain or SMS you want to check?\n"
read DOMAIN

total=$(mgmt_cli -r true -d $DOMAIN show objects --format json |jq '.total')
printf "There are $total objects\n"

for I in $(seq 0 500 $total)
do
 mgmt_cli -r true -d $DOMAIN show objects type "simple-gateway" details-level full offset $I limit 500 --format json | jq --raw-output '.objects[] | .name + "," + .hardware + .hwName + "," + .type + "," + ."ipv4-address"' >> $DOMAIN-hardware-list.txt
done

sed -i '1s/^/NAME,HARDWARE,TYPE,MGMT_IP\n/' $DOMAIN-hardware-list.txt
sed -i 's/CpmiGatewayCluster/Cluster/g' $DOMAIN-hardware-list.txt
sed -i 's/simple-gateway/Standalone/g' $DOMAIN-hardware-list.txt
sed -i 's/CpmiVsClusterNetobj/VS/g' $DOMAIN-hardware-list.txt
printf "\nYour Hardware List is located in $DOMAIN-hardware-list.txt\n"
