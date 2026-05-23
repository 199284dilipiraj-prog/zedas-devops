# ZEDAS Demo Customer Environment

A minimal, repeatable infrastructure setup for deploying a demo customer environment on Azure. Provisions a Linux VM running a containerised nginx web app using Terraform and Ansible, with a CI pipeline via GitHub Actions.

---

## Architecturecat > ~/zedas-devops/README.md << 'EOF'
# ZEDAS Demo Customer Environment

A minimal, repeatable infrastructure setup for deploying a demo customer environment on Azure. Provisions a Linux VM running a containerised nginx web app using Terraform and Ansible, with a CI pipeline via GitHub Actions.

---

## Architecture

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.3.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.12
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.40
- An Azure subscription
- An SSH key pair

---

## How to Deploy from Scratch

### 1. Clone the repository
```bash
git clone git@github.com:199284dilipiraj-prog/zedas-devops.git
cd zedas-devops
```

### 2. Login to Azure
```bash
az login
az account show
```

### 3. Generate SSH key
```bash
ssh-keygen -t rsa -b 4096 -C "zedas-demo" -f ~/.ssh/zedas_id_rsa
```

### 4. Create your tfvars file
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```
Edit `terraform.tfvars` with your values:
```hcl
customer_name       = "zedas-demo"
azure_region        = "norwayeast"
vm_size             = "Standard_B1s"
admin_username      = "azureuser"
ssh_public_key_path = "~/.ssh/zedas_id_rsa.pub"
allowed_ssh_ip      = "YOUR_IP/32"
```
Get your IP: `curl -s https://api.ipify.org`

### 5. Deploy infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```
Note the `public_ip_address` output.

### 6. Run Ansible playbook
```bash
cd ../ansible
ansible-playbook -i "PUBLIC_IP," playbook.yml \
  --user azureuser \
  --private-key ~/.ssh/zedas_id_rsa
```

### 7. Verify
Open your browser: `http://PUBLIC_IP` — you should see the nginx welcome page.

---

## How to Tear Down

```bash
cd terraform
terraform destroy
```
Type `yes` when prompted. All Azure resources will be deleted.

---

## Ansible vs cloud-init

Ansible was chosen over cloud-init for this setup because:
- It is idempotent — safe to re-run without side effects
- Easier to read, debug, and extend by other engineers
- Separates provisioning (Terraform) from configuration (Ansible) cleanly
- Cloud-init runs only once on first boot; Ansible can be re-applied anytime

---

## CI Pipeline

GitHub Actions runs on every pull request and push to `main`:

| Check | Tool |
|---|---|
| Terraform format | `terraform fmt -check` |
| Terraform validate | `terraform validate` |
| Terraform lint | `tflint` |
| Ansible lint | `ansible-lint` |

---

## Runbook — VM is Unreachable

Follow these steps in order:

- **Check Azure portal** — confirm the VM is in `Running` state under the resource group `rg-zedas-demo`
- **Check public IP** — run `terraform output public_ip_address` and confirm it matches what you are connecting to
- **Check NSG rules** — verify port 22 allows your current IP (`curl -s https://api.ipify.org`); your IP may have changed
- **Check VM boot diagnostics** — in Azure portal → VM → Boot diagnostics, look for kernel panic or disk errors
- **Try SSH** — `ssh -i ~/.ssh/zedas_id_rsa azureuser@PUBLIC_IP -v` and check verbose output for errors
- **Check Docker** — once SSH'd in, run `docker ps` to confirm nginx container is running
- **Check nginx container logs** — `docker logs nginx-demo` for any application errors
- **Check UFW firewall** — `sudo ufw status` to confirm ports 22 and 80 are allowed
- **Check port 80** — `curl -v http://localhost` from inside the VM to confirm nginx responds locally
- **Restart container if needed** — `docker restart nginx-demo`

---

## Trade-offs & Next Steps

### What was kept simple for this exercise
- Local Terraform state (no locking, not safe for teams)
- Single VM (no high availability)
- Self-signed or no TLS (HTTP only)
- Manual Ansible run (not triggered automatically)

### What I would improve with more time
- **Remote Terraform state** in Azure Storage with state locking
- **HTTPS** with Let's Encrypt or Azure Application Gateway
- **Terraform modules** to make the code reusable across customers
- **Ansible triggered from Terraform** using `remote-exec` provisioner or cloud-init for fully automated deploys
- **Azure Key Vault** for secret management
- **Monitoring** with Azure Monitor or Prometheus + Grafana
- **AKS** instead of a single VM for better resilience and scalability
