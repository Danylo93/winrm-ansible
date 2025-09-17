# 🚀 OBT Release Automation - Documentação

## 📋 Visão Geral

Sistema de automação para release do OBT seguindo padrões de mercado e melhores práticas de DevOps.

### 🏗️ Arquitetura

```
obt/
├── 📁 ansible/                    # Core Ansible
│   ├── 📁 inventories/            # Inventários por ambiente
│   │   ├── dev/hosts.yml          # Desenvolvimento
│   │   ├── hmg/hosts.yml          # Homologação
│   │   └── prd/hosts.yml          # Produção
│   ├── 📁 playbooks/              # Playbooks organizados
│   ├── 📁 roles/                  # Roles reutilizáveis
│   │   └── obt_release/           # Role principal
│   ├── 📁 group_vars/             # Variáveis por grupo
│   ├── 📁 host_vars/              # Variáveis por host
│   └── ansible.cfg                # Configuração Ansible
├── 📁 scripts/                    # Scripts de automação
├── 📁 configs/                    # Configurações por ambiente
├── 📁 docs/                       # Documentação
├── 📁 tests/                      # Testes automatizados
├── 📁 tools/                      # Ferramentas auxiliares
└── 📁 templates/                  # Templates reutilizáveis
```

## 🚀 Quick Start

### 1. Executar Deploy

```bash
# Deploy em desenvolvimento
./scripts/deploy.sh dev

# Deploy em produção (dry-run)
./scripts/deploy.sh prd --dry-run

# Deploy com tags específicas
./scripts/deploy.sh hmg --tags "deploy,validation"
```

### 2. Verificar Sintaxe

```bash
./scripts/deploy.sh dev --check
```

### 3. Deploy Verbose

```bash
./scripts/deploy.sh dev --verbose
```

## 🔧 Configuração

### Inventários

Cada ambiente possui seu próprio inventário em `ansible/inventories/{env}/hosts.yml`:

- **dev**: Desenvolvimento
- **hmg**: Homologação  
- **prd**: Produção

### Variáveis

- **defaults**: `ansible/roles/obt_release/defaults/main.yml`
- **por ambiente**: `ansible/inventories/{env}/hosts.yml`
- **por grupo**: `ansible/group_vars/`
- **por host**: `ansible/host_vars/`

## 📊 Funcionalidades

### ✅ Implementadas

- [x] Estrutura modular com roles
- [x] Inventários por ambiente
- [x] Limpeza automatizada de pastas
- [x] Deploy com backup automático
- [x] Validações pré e pós-deploy
- [x] Logging estruturado
- [x] Scripts de execução modernos

### 🔄 Em Desenvolvimento

- [ ] Testes automatizados
- [ ] Integração CI/CD
- [ ] Monitoramento e alertas
- [ ] Rollback automático
- [ ] Dashboard de métricas

## 🛠️ Desenvolvimento

### Estrutura de Roles

```
ansible/roles/obt_release/
├── defaults/main.yml      # Variáveis padrão
├── tasks/main.yml         # Task principal
├── tasks/cleanup.yml      # Limpeza de pastas
├── tasks/deploy.yml       # Deploy da aplicação
├── tasks/validation.yml   # Validações
├── handlers/main.yml      # Handlers
├── templates/            # Templates
└── meta/main.yml         # Metadados
```

### Adicionando Novos Ambientes

1. Criar inventário: `ansible/inventories/{env}/hosts.yml`
2. Configurar variáveis específicas
3. Testar conectividade: `ansible {env} -m win_ping`

### Adicionando Novos Clientes

Editar `ansible/roles/obt_release/defaults/main.yml`:

```yaml
cleanup_clients:
  argoweb:
    - { nome: "nx_novo_cliente", pasta: "nx_novo_cliente" }
  tmsweb:
    - { nome: "tms_novo_cliente", pasta: "tms_novo_cliente" }
```

## 🔒 Segurança

### Ansible Vault

```bash
# Criar arquivo criptografado
ansible-vault create ansible/inventories/prd/vault.yml

# Editar arquivo criptografado
ansible-vault edit ansible/inventories/prd/vault.yml

# Executar com vault
./scripts/deploy.sh prd --vault-password-file .vault_pass
```

### Variáveis Sensíveis

Sempre use vault para:
- Senhas
- Tokens de API
- Certificados
- Chaves privadas

## 📈 Monitoramento

### Logs

- **Ansible**: `logs/ansible.log`
- **Deploy**: `logs/deploy-{timestamp}.log`
- **Aplicação**: Configurado por ambiente

### Métricas

- Tempo de execução
- Taxa de sucesso
- Espaço liberado na limpeza
- Status dos serviços

## 🆘 Troubleshooting

### Problemas Comuns

1. **Conectividade WinRM**
   ```bash
   ansible dev -m win_ping
   ```

2. **Permissões**
   ```bash
   # Verificar usuário e permissões
   ansible dev -m win_whoami
   ```

3. **Sintaxe**
   ```bash
   ./scripts/deploy.sh dev --check
   ```

### Logs Detalhados

```bash
./scripts/deploy.sh dev --verbose
```

## 📞 Suporte

- **Documentação**: `docs/`
- **Issues**: Criar issue no repositório
- **Logs**: Verificar `logs/` para detalhes

---

**🎉 Sistema de Release Automatizada OBT - Versão 2.0**
