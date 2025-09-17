#!/bin/bash
# ==========================================
# 🧪 TESTE COMPLETO DE CI/CD
# ==========================================
# Simula o pipeline do GitHub Actions
# ==========================================

echo "==========================================="
echo "🧪 INICIANDO TESTE COMPLETO DE CI/CD"
echo "==========================================="

# Contador de testes
TESTS_PASSED=0
TESTS_FAILED=0

# Função para executar teste
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo ""
    echo "🔍 Executando: $test_name"
    echo "-------------------------------------------"
    
    if eval "$test_command"; then
        echo "✅ PASSOU: $test_name"
        ((TESTS_PASSED++))
    else
        echo "❌ FALHOU: $test_name"
        ((TESTS_FAILED++))
    fi
}

# 1. Teste de estrutura do projeto
run_test "📁 Estrutura do Projeto" '
    required_dirs=(
        "ansible/inventories/dev"
        "ansible/inventories/prd" 
        "ansible/playbooks"
        "ansible/roles/obt_release"
        "scripts"
        "docs"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            echo "❌ Diretório obrigatório não encontrado: $dir"
            exit 1
        fi
    done
    
    required_files=(
        "ansible/inventories/dev/hosts.yml"
        "ansible/playbooks/obt_release.yml"
        "ansible/roles/obt_release/tasks/main.yml"
        "scripts/test-vm.sh"
        "scripts/release-prd.sh"
        "README.md"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "❌ Arquivo obrigatório não encontrado: $file"
            exit 1
        fi
    done
    
    echo "✅ Estrutura do projeto validada"
'

# 2. Teste de sintaxe do playbook
run_test "✅ Sintaxe do Playbook" './test-syntax.sh'

# 3. Teste de validação da role
run_test "🎭 Validação da Role" './test-role.sh'

# 4. Teste de documentação
run_test "📚 Documentação" '
    if [ ! -s "README.md" ]; then
        echo "❌ README.md está vazio ou não existe"
        exit 1
    fi
    
    if [ ! -s "docs/FLUXO-RELEASE.md" ]; then
        echo "❌ Documentação de fluxo não encontrada"
        exit 1
    fi
    
    echo "✅ Documentação validada"
'

# 5. Teste de scripts
run_test "🔧 Validação de Scripts" '
    scripts=("scripts/test-vm.sh" "scripts/release-prd.sh" "scripts/deploy.sh" "run-obt.sh")
    
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            bash -n "$script" || {
                echo "❌ Erro de sintaxe em: $script"
                exit 1
            }
            echo "✅ Script validado: $script"
        else
            echo "⚠️ Script não encontrado: $script"
        fi
    done
'

# 6. Teste de inventários
run_test "📋 Validação de Inventários" '
    cd ansible
    
    inventories=("inventories/dev/hosts.yml" "inventories/prd/hosts.yml")
    
    for inventory in "${inventories[@]}"; do
        if [ -f "$inventory" ]; then
            ansible-inventory -i "$inventory" --list >/dev/null || {
                echo "❌ Inventory inválido: $inventory"
                exit 1
            }
            echo "✅ Inventory validado: $inventory"
        else
            echo "❌ Inventory não encontrado: $inventory"
            exit 1
        fi
    done
    
    cd ..
'

# 7. Teste de conectividade (se disponível)
run_test "🌐 Teste de Conectividade" '
    if command -v ansible >/dev/null 2>&1; then
        cd ansible
        export ANSIBLE_ROLES_PATH="$(pwd)/roles"
        export ANSIBLE_HOST_KEY_CHECKING="False"
        export ANSIBLE_DEPRECATION_WARNINGS="False"
        
        # Teste básico de conectividade (pode falhar se VM não estiver disponível)
        ansible dev -i inventories/dev/hosts.yml -m win_ping --timeout=10 >/dev/null 2>&1 || {
            echo "⚠️ VM não disponível para teste de conectividade (normal em CI)"
            exit 0
        }
        echo "✅ Conectividade testada"
        cd ..
    else
        echo "⚠️ Ansible não disponível para teste de conectividade"
        exit 0
    fi
'

# Resumo final
echo ""
echo "==========================================="
echo "📊 RESUMO DOS TESTES"
echo "==========================================="
echo "✅ Testes que passaram: $TESTS_PASSED"
echo "❌ Testes que falharam: $TESTS_FAILED"
echo "📊 Total de testes: $((TESTS_PASSED + TESTS_FAILED))"

if [ $TESTS_FAILED -eq 0 ]; then
    echo ""
    echo "🎉 TODOS OS TESTES PASSARAM!"
    echo "✅ O projeto está pronto para CI/CD"
    echo "✅ Pipeline do GitHub Actions deve funcionar"
    echo "==========================================="
    exit 0
else
    echo ""
    echo "❌ ALGUNS TESTES FALHARAM!"
    echo "⚠️ Corrija os problemas antes de fazer push"
    echo "==========================================="
    exit 1
fi
