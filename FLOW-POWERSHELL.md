## Demo flow in PowerShell

*Hint: define Shift-Enter as "Run selected text in active terminal" in VScode*

```powershell
# access TF
Set-Alias tf C:\Users\mkoldov\AppData\Local\Microsoft\WinGet\Links\terraform.exe
Set-Alias terraform C:\Users\mkoldov\AppData\Local\Microsoft\WinGet\Links\terraform.exe
# shortcut for kubectl
Set-Alias k kubectl

# easy SSH access to chkp and u1
code $env:USERPROFILE/.ssh/config
# Host cp
#    Hostname 68.219.229.203
#    IdentityFile /users/mkoldov/.ssh/azureshell.key
#    User admin
#    LogLevel ERROR
 
# Host u1
#    HostName 10.42.5.4
#    User azureuser
#    ProxyJump cp
#    IdentityFile ~/.ssh/u1tf.key

# make connection from U1
ssh u1 curl ip.iol.cz/ip/ -s

# check cluster readyness
terraform output -raw kube_config > $env:TEMP/k.config
$env:KUBECONFIG="$env:TEMP/k.config"

kubectl get nodes -o wide
kubectl get pods -n demo -o wide --show-labels
```