# Provisionamento de VM Windows + IIS + Milessis com Ansible

## Pastas
- `terraform/` → provisionamento da VM com WinRM
- `ansible/site.yml` → exemplo genérico de IIS
- `ansible/milessis.yml` → playbook completo do projeto Milessis
- `ansible/inventory_win.yml` → inventário com IP da VM

## Comandos

```bash
terraform init
terraform apply

# Edite o IP no inventory_win.yml

ansible-playbook -i ansible/inventory_win.yml ansible/milessis.yml
```

10.40.3.4
az.local/danylo.oliveira



comando em cada release:

ansible-playbook -i inventory_win.yml obt_release.yml
