- .ssh/config for cp-ademo 
-    mkdir ~/.ssh; cd ~/.ssh; touch authorized_keys; chmod 400 authorized_keys; chmod 700 .
- .ssh/config 
    Host cpademo
        Hostname 168.63.x.y
        User admin
        IdentityFile /users/mkoldov/.ssh/azureshell.key

terraform output
terraform output -raw ssh_key > $env:USERPROFILE/.ssh/u1tf.key
terraform output -raw ssh_key_pub >  $env:USERPROFILE/.ssh/u1tf.pub

scp $env:USERPROFILE/.ssh/u1tf* cpademo:.ssh/
ssh cpademo

- .ssh/config 
Host u1ademo
   HostName 10.42.5.4
    User azureuser
    ProxyJump cpademo
    IdentityFile ~/.ssh/u1tf.key

ssh cpademo:
    - sed -i '/AllowTcpForwarding no/c AllowTcpForwarding yes' /etc/ssh/sshd_config
    - service sshd restart
ssh u1ademo

SUBSCRIPTION_ID=f4ad5e85-ec75-4321-8854-ed7eb611f61d
az ad sp create-for-rbac --role="Reader" --scopes="/subscriptions/$SUBSCRIPTION_ID" -n cp-dcq-reader

# save secret


Policy:
ssh cpademo
https://sc1.checkpoint.com/documents/latest/APIs/#~v1.9%20

mgmt_cli -r true add host name "localhost" ip-address "127.0.0.1"
mgmt_cli -r true add network name "vnet42" subnet "10.42.0.0" subnet-mask "255.255.0.0"


to VNET 
from VNET 
rules

Topology and Hide NAT 
