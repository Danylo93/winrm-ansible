#!/bin/bash

# ==========================================
# 🚀 SCRIPT DE DEPLOY MODERNO
# ==========================================
# Script principal para execução de deploys
# Suporte a múltiplos ambientes e validações
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
log_debug() { [[ "${DEBUG:-}" == "true" ]] && echo -e "${PURPLE}[DEBUG]${NC} $1"; }

# Função de ajuda
show_help() {
    cat << EOF
🚀 Script de Deploy OBT

USAGE:
    $0 [OPTIONS] ENVIRONMENT

ENVIRONMENTS:
    dev         Ambiente de desenvolvimento
    hmg         Ambiente de homologação  
    prd         Ambiente de produção

OPTIONS:
    -h, --help              Mostrar esta ajuda
    -v, --verbose           Log detalhado
    -d, --dry-run          Executar sem fazer alterações
    -t, --tags TAGS        Executar apenas tags específicas
    -s, --skip-cleanup     Pular limpeza de pastas
    -c, --check            Verificar sintaxe apenas
    --vault-password-file  Arquivo com senha do vault

EXAMPLES:
    $0 dev                          # Deploy em desenvolvimento
    $0 prd --dry-run               # Teste em produção
    $0 hmg --tags "deploy"         # Apenas deploy em homologação
    $0 dev --skip-cleanup          # Deploy sem limpeza
    
EOF
}

# Validar ambiente
validate_environment() {
    local env="$1"
    case "$env" in
        dev|hmg|prd)
            return 0
            ;;
        *)
            log_error "Ambiente inválido: $env"
            log_info "Ambientes válidos: dev, hmg, prd"
            exit 1
            ;;
    esac
}

# Verificar pré-requisitos
check_prerequisites() {
    log_info "Verificando pré-requisitos..."
    
    # Verificar Ansible
    if ! command -v ansible-playbook &> /dev/null; then
        log_error "Ansible não encontrado!"
        exit 1
    fi
    
    # Verificar estrutura de diretórios
    if [[ ! -d "$ANSIBLE_DIR" ]]; then
        log_error "Diretório ansible não encontrado: $ANSIBLE_DIR"
        exit 1
    fi
    
    # Verificar inventário
    if [[ ! -f "$ANSIBLE_DIR/inventories/$ENVIRONMENT/hosts.yml" ]]; then
        log_error "Inventário não encontrado para ambiente: $ENVIRONMENT"
        exit 1
    fi
    
    log_success "Pré-requisitos verificados"
}

# Executar playbook
run_playbook() {
    local env="$1"
    shift
    local extra_args=("$@")
    
    log_info "Executando deploy para ambiente: $env"
    
    # Construir comando
    local cmd=(
        "ansible-playbook"
        "-i" "$ANSIBLE_DIR/inventories/$env/hosts.yml"
        "$ANSIBLE_DIR/playbooks/obt_release.yml"
        "--extra-vars" "environment=$env"
    )
    
    # Adicionar argumentos extras
    cmd+=("${extra_args[@]}")
    
    log_debug "Comando: ${cmd[*]}"
    
    # Executar
    cd "$ANSIBLE_DIR"
    "${cmd[@]}"
}

# Função principal
main() {
    local environment=""
    local ansible_args=()
    local dry_run=false
    local verbose=false
    
    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                ansible_args+=("-v")
                export DEBUG=true
                shift
                ;;
            -d|--dry-run)
                dry_run=true
                ansible_args+=("--check")
                shift
                ;;
            -t|--tags)
                ansible_args+=("--tags" "$2")
                shift 2
                ;;
            -s|--skip-cleanup)
                ansible_args+=("--skip-tags" "cleanup")
                shift
                ;;
            -c|--check)
                ansible_args+=("--syntax-check")
                shift
                ;;
            --vault-password-file)
                ansible_args+=("--vault-password-file" "$2")
                shift 2
                ;;
            -*)
                log_error "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
            *)
                if [[ -z "$environment" ]]; then
                    environment="$1"
                else
                    log_error "Múltiplos ambientes especificados"
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validar argumentos
    if [[ -z "$environment" ]]; then
        log_error "Ambiente não especificado"
        show_help
        exit 1
    fi
    
    validate_environment "$environment"
    export ENVIRONMENT="$environment"
    
    # Banner
    echo -e "${BLUE}"
    echo "=========================================="
    echo "🚀 DEPLOY OBT - AMBIENTE: ${environment^^}"
    echo "=========================================="
    echo -e "${NC}"
    
    if [[ "$dry_run" == "true" ]]; then
        log_warning "MODO DRY-RUN - Nenhuma alteração será feita"
    fi
    
    # Executar
    check_prerequisites
    run_playbook "$environment" "${ansible_args[@]}"
    
    # Sucesso
    echo -e "${GREEN}"
    echo "=========================================="
    echo "🎉 DEPLOY CONCLUÍDO COM SUCESSO!"
    echo "=========================================="
    echo -e "${NC}"
}

# Executar função principal
main "$@"
