```bash
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

---
```

```powershell
terraform output -raw cp-pass | Set-Clipboard
$cpip = terraform output -raw cp-public-ip
ssh admin@$cpip

scp /users/mkoldov/Downloads/cms.jar admin@$cpip:.

# gaia
# fix installation
cp $VSECDIR/lib/cms.jar $VSECDIR/lib/cms.jar.ORIG
cp /home/admin/cms.jar $VSECDIR/lib/cms.jar
ls -la $VSECDIR/lib/cms.jar*
vsec stop;vsec start
```

```bash
mgmt_cli -r true show software-packages-per-targets targets.1 "chkp" display.installed "no" display.recommended "any"

mgmt_cli -t true install-software-package name "Check_Point_R81_10_JUMBO_HF_MAIN_Bundle_T87_FULL.tgz"  package-location "automatic" targets.1 "chkp"

export MGMT_CLI_USER=admin
export MGMT_CLI_PASSWORD=H
mgmt_cli login --context gaia_api
mgmt_cli show hostname --context gaia_api
mgmt_cli show interfaces --context gaia_api

```

```bash
chkp> show installer packages
**  ************************************************************************* **
**                                 Hotfixes                                   **
**  ************************************************************************* **
Display name                                                                                    Status
R81.10 Jumbo Hotfix Accumulator Recommended Jumbo Take 87                                       Available for Download
chkp> inst
chkp> installer dow
download             - Download package
download-and-install - Download and install package
chkp> installer download-
chkp> installer download-and-install
**  ************************************************************************* **
**                                 Hotfixes                                   **
**  ************************************************************************* **
Num Display name                                                                                    Type
1   R81.10 Jumbo Hotfix Accumulator Recommended Jumbo Take 87                                       Hotfix
chkp> installer download-and-install 1
The machine will automatically reboot after download_install of Check_Point_R81_10_JUMBO_HF_MAIN_Bundle_T87_FULL.tgz.
Do you want to continue? ([y]es / [n]o / [s]uppress reboot)  y

Info: Initiating download_install of Check_Point_R81_10_JUMBO_HF_MAIN_Bundle_T87_FULL.tgz...
```

### create cluster
```bash
FRONT_PREFIX="10.42.3."
FRONT_NETMASK="255.255.255.0"
BACK_PREFIX="10.42.4."
BACK_NETMASK="255.255.255.0"
NODE1="25"
NODE2="26"
VIP="27"

PUBLIC_VIP="20.223.100.93"
PUBLIC_NODE1=""
PUBLIC_NODE2=""
SIC_KEY="jJXEaHiogoyyt8X66qZ8"

NODE1_ETH0_IP="${FRONT_PREFIX}${NODE1}"
NODE2_ETH0_IP="${FRONT_PREFIX}${NODE2}"
VIP_ETH0_IP="${FRONT_PREFIX}${VIP}"

NODE1_ETH1_IP="${BACK_PREFIX}${NODE1}"
NODE2_ETH1_IP="${BACK_PREFIX}${NODE2}"



mgmt_cli -r true add simple-cluster name "chkp-ha-second"\
    color "pink"\
    version "R81.10"\
    ip-address "${PUBLIC_VIP}"\
    os-name "Gaia"\
    cluster-mode "cluster-xl-ha"\
    firewall true\
    vpn false\
    interfaces.1.name "eth0"\
    interfaces.1.ip-address "${VIP_ETH0_IP}"\
    interfaces.1.network-mask "${FRONT_NETMASK}"\
    interfaces.1.interface-type "cluster + sync"\
    interfaces.1.topology "EXTERNAL"\
    interfaces.1.anti-spoofing false \
    interfaces.2.name "eth1"\
    interfaces.2.interface-type "sync"\
    interfaces.2.topology "INTERNAL"\
    interfaces.2.topology-settings.ip-address-behind-this-interface "network defined by the interface ip and net mask"\
    interfaces.2.topology-settings.interface-leads-to-dmz false\
    interfaces.2.anti-spoofing false \
    members.1.name "member1"\
    members.1.one-time-password "${SIC_KEY}"\
    members.1.ip-address "${NODE1_ETH0_IP}"\
    members.1.interfaces.1.name "eth0"\
    members.1.interfaces.1.ip-address "${NODE1_ETH0_IP}"\
    members.1.interfaces.1.network-mask "${FRONT_NETMASK}"\
    members.1.interfaces.2.name "eth1"\
    members.1.interfaces.2.ip-address "${NODE1_ETH1_IP}"\
    members.1.interfaces.2.network-mask "${BACK_NETMASK}"\
    members.2.name "member2"\
    members.2.one-time-password "${SIC_KEY}"\
    members.2.ip-address "${NODE2_ETH0_IP}"\
    members.2.interfaces.1.name "eth0"\
    members.2.interfaces.1.ip-address "${NODE2_ETH0_IP}"\
    members.2.interfaces.1.network-mask "${FRONT_NETMASK}"\
    members.2.interfaces.2.name "eth1"\
    members.2.interfaces.2.ip-address "${NODE2_ETH1_IP}"\
    members.2.interfaces.2.network-mask "${BACK_NETMASK}"\
    --format json

```