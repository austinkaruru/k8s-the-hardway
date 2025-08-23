# Reads machine information from machines.txt and configures each host
while read IP FQDN HOST SUBNET; do
echo "Configuring hostname for $HOST ($IP)..."
# Update /etc/hosts file to set localhost entry
CMD="sed -i 's/^127.0.1.1.*/127.0.1.1\t${FQDN} ${HOST}/' /etc/hosts"
ssh -o StrictHostKeyChecking=no -n root@${IP} "$CMD" < /dev/null
# Set the hostname
ssh -o StrictHostKeyChecking=no -n root@${IP} hostnamectl set-hostname ${HOST} < /dev/null     
# Restart hostname service
ssh -o StrictHostKeyChecking=no -n root@${IP} systemctl restart systemd-hostnamed < /dev/null     
echo "✅ Hostname configuration complete for $HOST"
done < machines.txt
echo "All hostnames configured successfully!"




server.europe-west4-a.c.k8s-thehardway-465822.internal
node-0.europe-west4-a.c.k8s-thehardway-465822.internal
node-1.europe-west4-a.c.k8s-thehardway-465822.internal


{instance-name}.{zone}.c.{project-id}.internal