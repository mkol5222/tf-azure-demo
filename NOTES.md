
## Login to Ubuntu
```bash
terraform output -raw ssh_key > /tmp/a.key; chmod 400 /tmp/a.key
ssh -i /tmp/a.key azureuser@$(terraform output -raw ssh_ip)
```
Powershell on Windows
```powershell
terraform output -raw ssh_key > $env:TEMP/a.key
$u1ip = terraform output -raw ssh_ip
ssh -i $env:TEMP/a.key azureuser@$u1ip
```

## Use AKS
```bash
terraform output -raw kube_config > /tmp/k.config
export KUBECONFIG=/tmp/k.config
kubectl get nodes
kubectl config view
```
Powershell on Windows
```powershell
# optional 
#   az login
#   az account list
terraform output -raw kube_config > $env:TEMP/k.config
$env:KUBECONFIG="$env:TEMP/k.config"
kubectl get nodes
```

## Management after initial start
```bash
# ssh to MGMT: ssh admin@68.219.229.203
clish -c 'set user admin shell /bin/bash' -s

# wait for FTCW
tail -f /var/log/ftw_install.log
# reboot happens

# PowerShell
gci ~/Downloads -rec cms.jar 
scp /users/mkoldov/Downloads/cms.jar admin@68.219.229.203:.

# ssh to MGMT: ssh admin@68.219.229.203
# install JHF 87 for R81.10
clish
# installer download 1
# installer install 1
# reboot happens

# ssh to MGMT: ssh admin@68.219.229.203
# confirm JHF 87
cpinfo -y all

# fix installation
cp $VSECDIR/lib/cms.jar $VSECDIR/lib/cms.jar.ORIG
cp /home/admin/cms.jar $VSECDIR/lib/cms.jar
ls -la $VSECDIR/lib/cms.jar*
vsec stop;vsec start

# enable API remote access
while true; do
    status=`api status |grep 'API readiness test SUCCESSFUL. The server is up and ready to receive connections' |wc -l`
    echo "Checking if the API is ready"
    if [[ ! $status == 0 ]]; then
         break
    fi
       sleep 15
    done
echo "API ready " `date`
sleep 5
echo "Set R80 API to accept all ip addresses"
mgmt_cli -r true set api-settings accepted-api-calls-from "All IP addresses" --domain 'System Data'
echo "Restarting API Server"
api restart

# objects
mgmt_cli -r true add host name "localhost" ip-address "127.0.0.1" 
mgmt_cli -r true add network name "net_10" subnet "10.0.0.0" subnet-mask "255.0.0.0"


mgmt_cli -r true set simple-gateway name 'chkp' interfaces.1.topology 'internal' interfaces.1.name 'eth1' interfaces.1.ipv4-address '10.42.4.4' interfaces.1.ipv4-mask-length '24' interfaces.1.topology-settings.ip-address-behind-this-interface 'specific' interfaces.1.topology-settings.specific-network 'net_10' interfaces.0.topology 'external' interfaces.0.name 'eth0' interfaces.0.ipv4-address '10.42.3.4' interfaces.0.ipv4-mask-length '24' "interfaces.0.anti-spoofing" false "interfaces.1.anti-spoofing" false nat-hide-internal-interfaces true

mgmt_cli -r true show simple-gateway name chkp -o json

# routes
clish -c 'set static-route 10.42.5.0/24 nexthop gateway address 10.42.4.1 on' -s
clish -c 'set static-route 10.42.1.0/24 nexthop gateway address 10.42.4.1 on' -s

# login with SmartConsole
```


## AKS
```
kubectl create ns demo
kubectl -n demo create deploy webka1 --image nginx --replicas 3

kubectl -n demo get pods -o wide --show-labels


```