# 🚀 Fluxo de Release OBT v2.0

## 🎯 **Cenário Real**

- **🧪 VM de DEV**: 10.60.7.11 - Para **testar** a automação
- **🚀 PRODUÇÃO**: Ambiente real - Onde acontece a **release real**

## 📋 **Fluxo Recomendado**

### **1. 🧪 Teste na VM de DEV (OBRIGATÓRIO)**

```bash
# Entrar no diretório
cd obt

# Teste básico na VM
./scripts/test-vm.sh

# Teste sem alterações (recomendado primeiro)
./scripts/test-vm.sh --dry-run

# Teste completo com validações
./scripts/test-vm.sh --full-test --verbose
```

**✅ O que é testado:**
- Conectividade com a VM
- Sintaxe do playbook
- Limpeza de pastas (limitada)
- Deploy do OBT
- Validações pós-deploy

### **2. 🚀 Release em PRODUÇÃO**

```bash
# SEMPRE teste primeiro em produção (dry-run)
./scripts/release-prd.sh --dry-run

# Se dry-run OK, release real (com confirmação)
./scripts/release-prd.sh

# Release com logs detalhados
./scripts/release-prd.sh --verbose
```

**⚠️ Confirmação de Segurança:**
- O script pedirá confirmação antes da execução real
- Digite `CONFIRMO` para prosseguir
- Certifique-se de que todos os pré-requisitos foram atendidos

## 🔧 **Configuração por Ambiente**

### **🧪 VM de DEV (Teste)**
- **Host**: 10.60.7.11
- **Usuário**: danylo.oliveira@az.local
- **Limpeza**: Apenas 2 clientes por tipo (teste)
- **Backup**: 3 dias de retenção
- **Azure DevOps**: Desabilitado

### **🚀 PRODUÇÃO (Real)**
- **Host**: Configurar no vault
- **Usuário**: Configurar no vault
- **Limpeza**: Todos os clientes (completa)
- **Backup**: 30 dias de retenção
- **Azure DevOps**: Habilitado

## 🛡️ **Segurança e Vault**

### **Configurar Vault para Produção**

```bash
# Criar arquivo vault para produção
ansible-vault create ansible/inventories/prd/vault.yml

# Conteúdo do vault (exemplo):
vault_prd_host: "IP_REAL_PRODUCAO"
vault_prd_user: "USUARIO_REAL_PRODUCAO"
vault_prd_password: "SENHA_REAL_PRODUCAO"
vault_azure_org: "SUA_ORG_AZURE"
vault_azure_project: "SEU_PROJETO_AZURE"
vault_azure_pipeline_id: "ID_PIPELINE_REAL"
vault_azure_pat: "TOKEN_REAL_AZURE_DEVOPS"
```

### **Arquivo de Senha do Vault**

```bash
# Criar arquivo com senha do vault (opcional)
echo "SUA_SENHA_VAULT" > .vault_pass
chmod 600 .vault_pass

# Adicionar ao .gitignore
echo ".vault_pass" >> .gitignore
```

## 📊 **Diferenças entre Ambientes**

| **Aspecto** | **VM de DEV** | **PRODUÇÃO** |
|-------------|---------------|--------------|
| **Objetivo** | Testar automação | Release real |
| **Host** | 10.60.7.11 | Configurado no vault |
| **Limpeza** | 2 clientes por tipo | Todos os clientes |
| **Backup** | 3 dias | 30 dias |
| **Validações** | Flexíveis | Rigorosas |
| **Azure DevOps** | Desabilitado | Habilitado |
| **Confirmação** | Não requer | Requer confirmação |

## 🔍 **Comandos de Diagnóstico**

### **Testar Conectividade**

```bash
# VM de DEV
cd ansible
ansible dev -m win_ping

# Produção (com vault)
ansible prd -m win_ping --vault-password-file ../.vault_pass
```

### **Verificar Sintaxe**

```bash
cd ansible

# Para DEV
ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --syntax-check

# Para PRD
ansible-playbook -i inventories/prd/hosts.yml playbooks/obt_release.yml --syntax-check --vault-password-file ../.vault_pass
```

### **Execução Manual (se necessário)**

```bash
cd ansible

# VM de DEV
ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --extra-vars "test_mode=true"

# Produção (dry-run)
ansible-playbook -i inventories/prd/hosts.yml playbooks/obt_release.yml --check --vault-password-file ../.vault_pass

# Produção (real)
ansible-playbook -i inventories/prd/hosts.yml playbooks/obt_release.yml --vault-password-file ../.vault_pass
```

## 📋 **Checklist de Release**

### **Antes da Release**
- [ ] ✅ Teste executado na VM de DEV com sucesso
- [ ] ✅ Vault configurado para produção
- [ ] ✅ Backup manual realizado
- [ ] ✅ Equipe notificada
- [ ] ✅ Janela de manutenção ativa
- [ ] ✅ Dry-run executado em produção

### **Durante a Release**
- [ ] ✅ Monitorar logs em tempo real
- [ ] ✅ Verificar cada etapa
- [ ] ✅ Confirmar funcionamento dos serviços

### **Após a Release**
- [ ] ✅ Verificar funcionamento da aplicação
- [ ] ✅ Monitorar logs de erro
- [ ] ✅ Notificar equipe sobre conclusão
- [ ] ✅ Documentar problemas encontrados

## 🆘 **Troubleshooting**

### **Problemas Comuns**

1. **Falha na conectividade**
   ```bash
   # Verificar WinRM
   ansible dev -m win_ping
   ```

2. **Erro de vault**
   ```bash
   # Verificar senha do vault
   ansible-vault view ansible/inventories/prd/vault.yml
   ```

3. **Falha na limpeza**
   ```bash
   # Executar apenas limpeza
   ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --tags "cleanup"
   ```

### **Logs Detalhados**

```bash
# Executar com máximo de logs
./scripts/test-vm.sh --verbose
./scripts/release-prd.sh --verbose
```

## 🎉 **Resumo do Novo Fluxo**

1. **🧪 TESTE**: `./scripts/test-vm.sh` na VM de DEV
2. **🔍 VALIDAÇÃO**: `./scripts/release-prd.sh --dry-run` em PRD
3. **🚀 RELEASE**: `./scripts/release-prd.sh` em PRD

**Simples, seguro e escalável!** 🚀
