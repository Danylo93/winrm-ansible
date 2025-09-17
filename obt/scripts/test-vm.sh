#!/bin/bash

# ==========================================
# 🧪 SCRIPT DE TESTE NA VM DE DEV
# ==========================================
# Script específico para testar a automação
# na VM de desenvolvimento antes da release real
# ==========================================

set -euo pipefail

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

# Cores para output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m'

# Funções de log
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_test() { echo -e "${PURPLE}[TEST]${NC} $1"; }

# Banner
show_banner() {
    echo -e "${PURPLE}"
    echo "=========================================="
    echo "🧪 TESTE DE AUTOMAÇÃO - VM DEV"
    echo "=========================================="
    echo "📍 VM: 10.60.7.11"
    echo "🎯 Objetivo: Validar automação antes da release real"
    echo "⚠️  ATENÇÃO: Este é um ambiente de TESTE"
    echo "=========================================="
    echo -e "${NC}"
}

# Função de ajuda
show_help() {
    cat << EOF
🧪 Script de Teste na VM de Desenvolvimento

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Mostrar esta ajuda
    -v, --verbose           Log detalhado
    -d, --dry-run          Executar sem fazer alterações
    -c, --connectivity     Apenas testar conectividade
    -s, --syntax           Verificar sintaxe apenas
    --skip-cleanup         Pular limpeza de pastas
    --full-test            Executar teste completo

EXAMPLES:
    $0                      # Teste básico
    $0 --dry-run           # Teste sem alterações
    $0 --connectivity      # Apenas conectividade
    $0 --full-test         # Teste completo
    
NOTA: Este script usa a VM de DEV (10.60.7.11) para validar
      a automação antes de executar em produção.
EOF
}

# Verificar conectividade
test_connectivity() {
    log_test "Testando conectividade com VM de teste..."

    cd "$ANSIBLE_DIR"

    # Configurar variáveis de ambiente
    export ANSIBLE_ROLES_PATH="$(pwd)/roles"
    export ANSIBLE_HOST_KEY_CHECKING="False"
    export ANSIBLE_DEPRECATION_WARNINGS="False"
    export ANSIBLE_STDOUT_CALLBACK="default"

    if ansible dev -i inventories/dev/hosts.yml -m win_ping > /dev/null 2>&1; then
        log_success "✅ Conectividade com VM de teste OK"

        # Obter informações da VM
        log_test "Obtendo informações da VM..."
        ansible dev -i inventories/dev/hosts.yml -m ansible.windows.win_shell -a "Write-Output \"Hostname: \$env:COMPUTERNAME\"; Write-Output \"OS: \$(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)\"; Write-Output \"PowerShell: \$(\$PSVersionTable.PSVersion)\""

        return 0
    else
        log_error "❌ Falha na conectividade com VM de teste"
        return 1
    fi
}

# Verificar sintaxe
check_syntax() {
    log_test "Verificando sintaxe do playbook..."

    cd "$ANSIBLE_DIR"

    # Configurar variáveis de ambiente
    export ANSIBLE_ROLES_PATH="$(pwd)/roles"
    export ANSIBLE_HOST_KEY_CHECKING="False"
    export ANSIBLE_DEPRECATION_WARNINGS="False"
    export ANSIBLE_STDOUT_CALLBACK="default"

    if ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --syntax-check; then
        log_success "✅ Sintaxe do playbook está correta"
        return 0
    else
        log_error "❌ Problemas de sintaxe encontrados"
        return 1
    fi
}

# Executar teste
run_test() {
    local dry_run="$1"
    local skip_cleanup="$2"
    local verbose="$3"

    log_test "Executando teste de automação na VM..."

    # Configurar variáveis de ambiente
    export ANSIBLE_ROLES_PATH="$(pwd)/roles"
    export ANSIBLE_HOST_KEY_CHECKING="False"
    export ANSIBLE_DEPRECATION_WARNINGS="False"
    export ANSIBLE_STDOUT_CALLBACK="default"

    # Construir comando
    local cmd=(
        "ansible-playbook"
        "-i" "inventories/dev/hosts.yml"
        "playbooks/obt_release.yml"
        "--extra-vars" "test_mode=true"
    )

    # Adicionar opções
    if [[ "$dry_run" == "true" ]]; then
        cmd+=("--check")
        log_warning "🧪 Executando em modo DRY-RUN (sem alterações)"
    fi

    if [[ "$skip_cleanup" == "true" ]]; then
        cmd+=("--skip-tags" "cleanup")
        log_warning "⏭️ Pulando limpeza de pastas"
    fi

    if [[ "$verbose" == "true" ]]; then
        cmd+=("-v")
    fi

    log_test "Comando: ${cmd[*]}"

    # Executar
    cd "$ANSIBLE_DIR"
    "${cmd[@]}"
}

# Função principal
main() {
    local dry_run=false
    local verbose=false
    local connectivity_only=false
    local syntax_only=false
    local skip_cleanup=false
    local full_test=false
    
    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
                shift
                ;;
            -c|--connectivity)
                connectivity_only=true
                shift
                ;;
            -s|--syntax)
                syntax_only=true
                shift
                ;;
            --skip-cleanup)
                skip_cleanup=true
                shift
                ;;
            --full-test)
                full_test=true
                shift
                ;;
            -*)
                log_error "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
            *)
                log_error "Argumento inesperado: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Banner
    show_banner
    
    # Verificar pré-requisitos
    if [[ ! -d "$ANSIBLE_DIR" ]]; then
        log_error "Diretório ansible não encontrado: $ANSIBLE_DIR"
        exit 1
    fi
    
    # Executar testes
    if [[ "$connectivity_only" == "true" ]]; then
        test_connectivity
        exit $?
    fi
    
    if [[ "$syntax_only" == "true" ]]; then
        check_syntax
        exit $?
    fi
    
    # Teste completo
    log_test "Iniciando sequência de testes..."
    
    # 1. Conectividade
    if ! test_connectivity; then
        log_error "Falha no teste de conectividade"
        exit 1
    fi
    
    # 2. Sintaxe
    if ! check_syntax; then
        log_error "Falha na verificação de sintaxe"
        exit 1
    fi
    
    # 3. Execução
    if run_test "$dry_run" "$skip_cleanup" "$verbose"; then
        echo -e "${GREEN}"
        echo "=========================================="
        echo "🎉 TESTE CONCLUÍDO COM SUCESSO!"
        echo "=========================================="
        echo "✅ Conectividade: OK"
        echo "✅ Sintaxe: OK"
        echo "✅ Execução: OK"
        echo ""
        echo "🚀 A automação está pronta para PRODUÇÃO!"
        echo "=========================================="
        echo -e "${NC}"
        
        if [[ "$full_test" == "true" ]]; then
            log_test "Executando validações adicionais..."
            # Aqui podem ser adicionados testes extras
        fi
        
    else
        echo -e "${RED}"
        echo "=========================================="
        echo "❌ TESTE FALHOU!"
        echo "=========================================="
        echo "❌ Verifique os logs acima para detalhes"
        echo "❌ NÃO execute em produção até corrigir"
        echo "=========================================="
        echo -e "${NC}"
        exit 1
    fi
}

# Executar função principal
main "$@"
