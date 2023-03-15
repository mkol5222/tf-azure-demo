
Login to Ubuntu
```bash
terraform output -raw ssh_key > /tmp/a.key; chmod 400 /tmp/a.key
ssh -i /tmp/a.key azureuser@$(terraform output -raw ssh_ip)
```
Powershell Windows
```powershell

```

Use AKS
```bash
terraform output -raw kube_config > /tmp/k.config
export KUBE_CONFIG=/tmp/k.config
kubectl get nodes
kubectl config view
```


Management after initial start
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

# fix installation
cp $VSECDIR/lib/cms.jar $VSECDIR/lib/cms.jar.ORIG
cp /home/admin/cms.jar $VSECDIR/lib/cms.jar
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


```