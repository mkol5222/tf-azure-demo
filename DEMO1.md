```powershell
# pods in demo - focus on IP and labels
kubectl get pods -n demo -o wide --show-labels

# traffic from all Pods in NS demo
kubectl get pods -n demo -o name  | % { Write-Host $_; kubectl -n demo exec -it $_ -- curl -s -m1 ip.iol.cz/ip/; Write-Host  }

# pods in DEFAULT NS
kubectl get pods -n default -o wide --show-labels
# traffic from DEFAULT dropped
kubectl get pods -n default -o name  | % { Write-Host $_; kubectl -n default exec -it $_ -- curl -s -m1 ip.iol.cz/ip/; Write-Host  }

# pods in DEFAULT
kubectl get pods -n default -o wide --show-labels
# even superman is dropped
kubectl get pods -n default -o name  | % { Write-Host $_; kubectl -n default exec -it $_ -- curl -s -m1 ip.iol.cz/ip/; Write-Host  }

# POLICY UPDATE - superman accepted
kubectl get pods -n default -o name  | % { Write-Host $_; kubectl -n default exec -it $_ -- curl -s -m1 ip.iol.cz/ip/; Write-Host  }

```