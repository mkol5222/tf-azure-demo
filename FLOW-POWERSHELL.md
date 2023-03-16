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

# Management readyness
ssh cp 
# watch -n 10 -d api status

# make connection from U1
ssh u1 curl ip.iol.cz/ip/ -s

# check VM tags
az vm show --resource-group rg-ademo --name ubuntu1 --query tags
# put u1 to prod
az vm update --resource-group rg-ademo --name ubuntu1 --set tags.env=prod tags.app=ubuntu
# put u1 to test
az vm update --resource-group rg-ademo --name ubuntu1 --set tags.env=test tags.app=ubuntu

# check cluster readyness
terraform output -raw kube_config > $env:TEMP/k.config
$env:KUBECONFIG="$env:TEMP/k.config"

kubectl get nodes -o wide
kubectl get pods -n demo -o wide --show-labels

# make connection from pods in ns demo:
kubectl get pods -n demo -o name -l app=webka1 | % { Write-Host $_; kubectl -n demo exec -it $_ -- curl -s -m1 ip.iol.cz/ip/; Write-Host  }
# scale app up
kubectl -n demo scale deploy webka1 --replicas 6
kubectl get pods -n demo -o wide --show-labels
# scale app down
kubectl -n demo scale deploy webka1 --replicas 3
kubectl get pods -n demo -o wide --show-labels

# put all to prod
kubectl get pods -n demo -o name -l app=webka1 | % { kubectl -n demo label $_ env=prod --overwrite  }
kubectl get pods -n demo -o wide --show-labels
# put all to test
kubectl get pods -n demo -o name -l app=webka1 | % { kubectl -n demo label $_ env=test --overwrite  }
kubectl get pods -n demo -o wide --show-labels

# put first to prod
kubectl get pods -n demo -o name -l app=webka1 | select -first 1 | % { kubectl -n demo label $_ env=prod --overwrite  }
kubectl get pods -n demo -o wide --show-labels

# put last to test
kubectl get pods -n demo -o name -l app=webka1 | select -last 1 | % { kubectl -n demo label $_ env=test --overwrite  }
kubectl get pods -n demo -o wide --show-labels

```