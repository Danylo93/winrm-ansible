# Automação IIS Milessis com Ansible

Este repositório provisiona e publica aplicações no IIS (classic e nextgen) de forma idempotente, com fallback local quando o caminho UNC não existir, bindings HTTP/HTTPS opcionais, ACLs e páginas de verificação.

---

## ✅ Pré‑requisitos

**Control node (WSL/Ubuntu ou Linux):**

* `ansible-core` ≥ 2.16
* Collections: `ansible.windows`, `community.windows`

Instalação recomendada (APT, sem venv):

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible-core python3-winrm python3-requests-ntlm
ansible --version
```

Coleções:

```bash
cd ansible
ansible-galaxy collection install -r collections/requirements.yml
```

**Windows target:**

* WinRM HTTP (5985) habilitado.
* Usuário admin local (ou com permissão para instalar features IIS e gerenciar sites).
* Porta 80 liberada no firewall / NSG, se acesso externo for necessário.

---

## 📁 Estrutura do projeto

```
ansible/
├─ ansible.cfg
├─ collections/
│  └─ requirements.yml
├─ inventories/
│  ├─ dev/
│  │  ├─ hosts.yml
│  │  └─ group_vars/
│  │     └─ win.yml
│  ├─ hmg/
│  │  └─ hosts.yml
│  └─ prd/
│     └─ hosts.yml
├─ playbooks/
│  └─ deploy_iis.yml
└─ roles/
   ├─ windows_baseline/
   │  └─ tasks/main.yml
   └─ iis_site/
      ├─ defaults/main.yml
      ├─ handlers/main.yml
      └─ tasks/*.yml  (install_iis, site, bindings, pools, paths, apps, acl, content, https)
```

> Dica: O `ansible.cfg` já aponta `collections_paths` e um inventário padrão. Se você executar fora da pasta `ansible/`, exporte `ANSIBLE_CONFIG` para o arquivo correto.

---

## 🔧 Configuração por ambiente

Edite `ansible/inventories/dev/group_vars/win.yml`:

```yaml
iis_sites:
  - name: "www.argoit.com.br"
    hostname: "www.argoit.com.br"
    ip: "*"
    http_port: 80
    enable_https: false
    https_port: 443
    cert_store_name: "WebHosting"
    cert_thumbprint: ""

    managed_runtime: "v4.0"
    pipeline_mode: "Integrated"
    start_mode: "AlwaysRunning"

    classic_path: "\\\\fileserverus\\Aplicacoes\\useargo\\tmsweb\\tms_argo09"
    nextgen_path: "\\\\fileserverus\\Aplicacoes\\useargo\\argoweb\\nx_argo09"
    fallback_classic_local: "C:\\Sites\\milessis.classic"
    fallback_nextgen_local: "C:\\Sites\\milessis.nextgen"

    pools:
      - name: "milessis.classic"
      - name: "milessis.nextgen"

    apps:
      - path: "/milessis"
        physical: "classic"
        pool: "milessis.classic"
      - path: "/milessis/nx"
        physical: "nextgen"
        pool: "milessis.nextgen"
```

Inventário (ex.: `ansible/inventories/dev/hosts.yml`):

```yaml
win:
  hosts:
    vm-obt:
      ansible_host: 40.71.19.152
      ansible_user: azureuser
      ansible_password: SenhaForte123!
      ansible_connection: winrm
      ansible_port: 5985
      ansible_winrm_transport: basic
      ansible_winrm_server_cert_validation: ignore
```

> **Segurança:** mova senhas para Ansible Vault quando necessário.

---

## ▶️ Como rodar

1. **Instalar coleções** (uma vez por máquina):

```bash
cd ansible
ansible-galaxy collection install -r collections/requirements.yml
```

2. **Dry‑run (check mode)**:

```bash
ansible-playbook -i inventories/dev/hosts.yml playbooks/deploy_iis.yml --check --diff
```

3. **Aplicar mudanças**:

```bash
ansible-playbook -i inventories/dev/hosts.yml playbooks/deploy_iis.yml
```

### Execuções úteis

* Limitar a um host específico:

```bash
ansible-playbook -i inventories/dev/hosts.yml playbooks/deploy_iis.yml -l vm-obt
```

* Rodar só uma parte (tags):

```bash
ansible-playbook -i inventories/dev/hosts.yml playbooks/deploy_iis.yml --tags pools,apps
```

* Repetir a partir de uma task:

```bash
ansible-playbook -i inventories/dev/hosts.yml playbooks/deploy_iis.yml --start-at-task "Publish applications"
```

* Verbosidade extra:

```bash
ansible-playbook -vvv -i inventories/dev/hosts.yml playbooks/deploy_iis.yml
```

### Habilitar HTTPS

No `win.yml` do ambiente, defina:

```yaml
enable_https: true
cert_thumbprint: "ABCD1234..."    # do certificado instalado no store "WebHosting"
```

E rode o play novamente.

---

## ✅ Verificação pós‑deploy

Na **VM Windows** (PowerShell Admin):

```powershell
Import-Module WebAdministration
Get-WebBinding -Name 'www.argoit.com.br' | fl protocol,bindingInformation,hostHeader
Get-WebApplication -Site 'www.argoit.com.br' | select path,physicalPath,applicationPool
Get-WebAppPoolState 'milessis.classic','milessis.nextgen'

# Testes com host header
Invoke-WebRequest -Headers @{Host='www.argoit.com.br'} http://127.0.0.1/milessis -UseBasicParsing | Select StatusCode
Invoke-WebRequest -Headers @{Host='www.argoit.com.br'} http://127.0.0.1/milessis/nx -UseBasicParsing | Select StatusCode
```

> O site usa host header; para testar via navegador local, adicione `127.0.0.1  www.argoit.com.br` no `hosts` da VM (ou adicione um binding extra sem host header).

---

## 🧰 Troubleshooting rápido

* **"couldn't resolve module 'ansible.windows.\*'"** → instale/atualize coleções: `ansible-galaxy collection install -r collections/requirements.yml`.
* **WinRM falhando** → valide: `ansible -i inventories/dev/hosts.yml -m ansible.windows.win_ping all`.
* **HTTP 404** em `/milessis` → checar host header/binding; criar `index.html` (já automatizado).
* **HTTP 503** → verifique App Pools (estado/identidade); o role usa `ApplicationPoolIdentity` e aplica ACLs automaticamente.
* **UNC inexistente** → o role faz fallback para `C:\Sites\...` automaticamente.

---

## 🌱 Escalando para HMG/PRD

* Copie `inventories/dev` → `inventories/hmg` e `inventories/prd`.
* Ajuste IPs/credenciais (use **Vault** em PRD) e variáveis (thumbprint HTTPS).
* Execute trocando o inventário:

```bash
ansible-playbook -i inventories/prd/hosts.yml playbooks/deploy_iis.yml
```

---

## 🔒 Boas práticas

* **Vault** para segredos: `ansible-vault create group_vars/win/vault.yml`.
* **CI**: habilite o workflow `.github/workflows/ansible-ci.yml` para lint e check‑mode em cada PR.
* **Idempotência**: use `--check --diff` antes de aplicar.
* **Tags** para entregar rápido apenas o que mudou (ex.: `--tags apps`).

---

## Comandos de diagnóstico úteis

```bash
# Inventário e variáveis resolvidas
ansible-inventory -i inventories/dev/hosts.yml --graph
ansible-inventory -i inventories/dev/hosts.yml --host vm-obt

# Ping e módulo de features
ansible -i inventories/dev/hosts.yml -m ansible.windows.win_ping all
ansible-playbook -i inventories/dev/hosts.yml playbooks/deploy_iis.yml --tags baseline --check
```

---

## Remoção (teardown) **opcional**

Crie um play `playbooks/teardown_iis.yml` com `state: absent` para `win_iis_webapplication`, `win_iis_webbinding` e `win_iis_website` se precisar desprovisionar.

---

## Release DEV (parar IIS → disparar pipeline → reiniciar)

1. Defina as variáveis do Azure DevOps em `ansible/inventories/dev/group_vars/win.yml`:

```yaml
azure_devops_org: "SEU_ORG"
azure_devops_project: "SEU_PROJETO"
azure_devops_pipeline_id: "123"  # ID YAML pipeline
```

2. Exporte o PAT no controlador (não salve a senha em arquivo):

```bash
export AZURE_DEVOPS_PAT=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

3. Rode o playbook de release DEV (logs claros + arquivo `ansible/ansible-dev-release.log`):

```bash
cd ansible
ansible-playbook playbooks/release_dev.yml
```

O playbook executa:
- Stop do IIS (serviço `W3SVC`)
- Disparo do pipeline no Azure DevOps e espera até a conclusão
- Start + restart do IIS (`iisreset /restart`)

Erros no pipeline causam falha do playbook, mantendo a reativação do IIS ao final para não deixar o host offline.
