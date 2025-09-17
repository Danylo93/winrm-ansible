# 🚀 CI/CD Pipeline - OBT Release

Documentação do pipeline de CI/CD para automação do OBT.

## 🎯 Visão Geral

O pipeline de CI/CD é executado automaticamente em:
- **Push** para branches `main` e `develop`
- **Pull Requests** para branch `main`
- **Alterações** na pasta `obt/` ou no workflow

## 📋 Jobs do Pipeline

### 1. 🔍 **Lint and Validate**
- **Objetivo**: Validar sintaxe e qualidade do código
- **Ferramentas**: `yamllint`, `ansible-lint`
- **Validações**:
  - ✅ Sintaxe YAML
  - ✅ Boas práticas Ansible
  - ✅ Sintaxe do playbook

### 2. 🛡️ **Security Scan**
- **Objetivo**: Verificar segurança do código
- **Validações**:
  - ✅ Senhas hardcoded
  - ✅ Arquivos vault criptografados
  - ✅ Configurações sensíveis

### 3. 🧪 **Test Project Structure**
- **Objetivo**: Validar estrutura do projeto
- **Validações**:
  - ✅ Diretórios obrigatórios
  - ✅ Arquivos essenciais
  - ✅ Organização padrão

### 4. 📚 **Documentation Check**
- **Objetivo**: Verificar documentação
- **Validações**:
  - ✅ README.md presente
  - ✅ Documentação de fluxo
  - ✅ Conteúdo não vazio

### 5. 🎭 **Role Validation**
- **Objetivo**: Validar roles Ansible
- **Validações**:
  - ✅ Estrutura da role
  - ✅ Arquivos obrigatórios
  - ✅ Metadados corretos

### 6. 🔧 **Scripts Validation**
- **Objetivo**: Validar scripts shell
- **Validações**:
  - ✅ Sintaxe bash
  - ✅ Permissões de execução
  - ✅ Scripts essenciais

### 7. 📋 **Inventory Validation**
- **Objetivo**: Validar inventários
- **Validações**:
  - ✅ Sintaxe YAML
  - ✅ Estrutura Ansible
  - ✅ Inventários por ambiente

### 8. 📊 **Build Summary**
- **Objetivo**: Resumo final do build
- **Saída**: Status de todos os jobs

## 🔧 Configurações

### **yamllint** (`.yamllint.yml`)
```yaml
extends: default
rules:
  line-length:
    max: 120
  indentation:
    spaces: 2
```

### **ansible-lint** (`.ansible-lint`)
```yaml
profile: production
skip_list:
  - yaml[line-length]
  - name[casing]
```

## 🚀 Como Usar

### **Desenvolvimento Local**
```bash
# Executar lints localmente
cd obt
yamllint ansible/
ansible-lint ansible/

# Validar sintaxe
cd ansible
ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --syntax-check
```

### **Triggers do Pipeline**
- **Push para main/develop**: Pipeline completo
- **Pull Request**: Validação completa
- **Alterações em obt/**: Execução automática

## 📈 Status do Pipeline

O pipeline deve passar em todos os jobs para:
- ✅ **Merge** de Pull Requests
- ✅ **Deploy** em ambientes
- ✅ **Release** de versões

## 🔍 Troubleshooting

### **Erro de Lint YAML**
```bash
# Verificar localmente
yamllint obt/ansible/
```

### **Erro de Lint Ansible**
```bash
# Verificar localmente
cd obt
ansible-lint ansible/
```

### **Erro de Sintaxe**
```bash
# Verificar localmente
cd obt/ansible
ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --syntax-check
```

### **Erro de Estrutura**
- Verificar se todos os diretórios obrigatórios existem
- Verificar se todos os arquivos essenciais estão presentes
- Seguir a estrutura documentada no README.md

## 🎯 Próximos Passos

### **Melhorias Futuras**
- [ ] Testes de integração
- [ ] Deploy automático para staging
- [ ] Notificações Slack/Teams
- [ ] Métricas de qualidade
- [ ] Testes de performance

### **Integração com Ambientes**
- [ ] Deploy automático para DEV
- [ ] Aprovação manual para PRD
- [ ] Rollback automático
- [ ] Monitoramento pós-deploy

---

## 🎉 **Pipeline Moderno e Robusto!**

O pipeline de CI/CD garante:
- ✅ **Qualidade** do código
- ✅ **Segurança** das configurações
- ✅ **Consistência** da estrutura
- ✅ **Documentação** atualizada

**Desenvolvido seguindo as melhores práticas de DevOps!** 🚀
