
Login to Ubuntu
```bash
terraform output -raw ssh_key > /tmp/a.key; chmod 400 /tmp/a.key
ssh -i /tmp/a.key azureuser@$(terraform output -raw ssh_ip)
```

Use AKS
```bash
terraform output -raw kube_config > /tmp/k.config
export KUBE_CONFIG=/tmp/k.config
kubectl get nodes
kubectl config view
```
