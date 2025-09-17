# 🚀 OBT Release Automation v2.0

Sistema de automação para release do OBT seguindo **padrões de mercado** e **melhores práticas de DevOps**.

## 🎯 Principais Melhorias

### ✅ **Estrutura Escalável**
- **Roles modulares** para reutilização
- **Inventários por ambiente** (dev/hmg/prd)
- **Configurações centralizadas**
- **Scripts modernos** com validações

### ✅ **Padrões de Mercado**
- **Ansible Galaxy** structure
- **GitOps** ready
- **CI/CD** integration
- **Infrastructure as Code**

### ✅ **Segurança e Governança**
- **Ansible Vault** para credenciais
- **Validações automáticas**
- **Logs estruturados**
- **Rollback capabilities**

## 🚀 Quick Start

### **🧪 1. Testar na VM de DEV (SEMPRE PRIMEIRO)**
```bash
# Teste básico na VM
./scripts/test-vm.sh

# Teste sem alterações (dry-run)
./scripts/test-vm.sh --dry-run

# Teste completo com logs
./scripts/test-vm.sh --full-test --verbose
```

### **🚀 2. Release Real em PRODUÇÃO**
```bash
# SEMPRE teste primeiro em produção (dry-run)
./scripts/release-prd.sh --dry-run

# Release real (com confirmação de segurança)
./scripts/release-prd.sh

# Release com logs detalhados
./scripts/release-prd.sh --verbose
```

### **📋 3. Fluxo Recomendado**
```bash
# 1. Testar na VM de DEV
./scripts/test-vm.sh --full-test

# 2. Se teste OK, dry-run em PRD
./scripts/release-prd.sh --dry-run

# 3. Se dry-run OK, release real
./scripts/release-prd.sh
```

## 📁 Estrutura Limpa e Organizada

```
obt/
├── 📁 ansible/                    # ✅ Core Ansible
│   ├── 📁 inventories/            # ✅ Inventários por ambiente
│   │   ├── dev/hosts.yml          # 🧪 VM de teste (10.60.7.11)
│   │   ├── hmg/hosts.yml          # 🧪 Homologação
│   │   └── prd/hosts.yml          # 🚀 Produção (com vault)
│   ├── 📁 playbooks/              # ✅ Playbooks organizados
│   │   └── obt_release.yml        # ✅ Playbook principal
│   ├── 📁 roles/                  # ✅ Roles modulares
│   │   └── obt_release/           # ✅ Role principal do OBT
│   │       ├── tasks/             # ✅ Tasks modulares
│   │       ├── defaults/          # ✅ Variáveis padrão
│   │       ├── handlers/          # ✅ Handlers
│   │       └── meta/              # ✅ Metadados
│   ├── 📁 group_vars/             # ✅ Variáveis por grupo
│   ├── 📁 host_vars/              # ✅ Variáveis por host
│   └── ansible.cfg                # ✅ Configuração otimizada
├── 📁 scripts/                    # ✅ Scripts modernos
│   ├── deploy.sh                  # ✅ Deploy genérico
│   ├── test-vm.sh                 # ✅ Teste na VM
│   └── release-prd.sh             # ✅ Release produção
├── 📁 docs/                       # ✅ Documentação
│   ├── README.md                  # ✅ Documentação técnica
│   └── FLUXO-RELEASE.md           # ✅ Fluxo de release
├── 📁 logs/                       # ✅ Logs do Ansible
├── 📁 cache/                      # ✅ Cache do Ansible
├── run-obt.sh                     # ✅ Script principal
└── README.md                      # ✅ Documentação principal
```

## 🔧 Configuração por Ambiente

### **Desenvolvimento (dev)**
- VM de teste: 10.60.7.11
- Validações básicas
- Backup 3 dias
- Azure DevOps desabilitado
- Limpeza limitada (2 clientes por tipo)

### **Produção (prd)**
- Servidor real (configurado no vault)
- Validações rigorosas
- Backup 30 dias
- Azure DevOps habilitado
- Limpeza completa (todos os clientes)

## 🛡️ Segurança

### **Ansible Vault**
```bash
# Criar vault para produção
ansible-vault create ansible/inventories/prd/vault.yml

# Executar com vault
./scripts/release-prd.sh --vault-password-file .vault_pass
```

## 📊 Funcionalidades

### **✅ Implementadas**
- [x] Estrutura modular escalável
- [x] Inventários por ambiente
- [x] Limpeza automatizada de pastas
- [x] Deploy com backup automático
- [x] Validações pré e pós-deploy
- [x] Logging estruturado
- [x] Scripts modernos com validações
- [x] Suporte a múltiplos ambientes
- [x] Ansible Vault integration

## 🎯 Benefícios da Nova Estrutura

### **🔄 Escalabilidade**
- **Roles reutilizáveis** entre projetos
- **Inventários modulares** por ambiente
- **Configurações centralizadas**
- **Fácil adição** de novos ambientes

### **🛡️ Governança**
- **Separação clara** de responsabilidades
- **Versionamento** de configurações
- **Auditoria completa** de mudanças
- **Aprovações** por ambiente

### **⚡ Performance**
- **Execução paralela** otimizada
- **Cache** de facts
- **Logs estruturados**
- **Validações eficientes**

## 🆘 Suporte

### **Execução Rápida**
```bash
# Verificar conectividade
cd ansible
ansible dev -i inventories/dev/hosts.yml -m win_ping

# Teste de sintaxe
./run-obt.sh --dry-run

# Deploy com logs
./run-obt.sh --verbose
```

### **Troubleshooting**
```bash
# Logs detalhados
tail -f logs/ansible.log

# Verificar configuração
cd ansible
ansible-config dump
```

---

## 🎉 **Estrutura Limpa e Pronta para Produção!**

A nova estrutura segue as **melhores práticas** da indústria:
- ✅ **Ansible Galaxy** structure
- ✅ **GitOps** principles  
- ✅ **Infrastructure as Code**
- ✅ **DevOps** best practices
- ✅ **Enterprise** ready

**Execute agora:** `./scripts/test-vm.sh` 🚀
