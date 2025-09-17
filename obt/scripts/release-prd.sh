#!/bin/bash

# ==========================================
# 🚀 SCRIPT DE RELEASE PRODUÇÃO
# ==========================================
# Script para execução da release REAL em produção
# ATENÇÃO: Este script executa em ambiente REAL!
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
log_prod() { echo -e "${PURPLE}[PRODUÇÃO]${NC} $1"; }

# Banner de produção
show_banner() {
    echo -e "${RED}"
    echo "=========================================="
    echo "🚀 RELEASE PRODUÇÃO - OBT"
    echo "=========================================="
    echo "⚠️  ATENÇÃO: AMBIENTE DE PRODUÇÃO!"
    echo "🎯 Esta é a release REAL do OBT"
    echo "📅 Data: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "=========================================="
    echo -e "${NC}"
}

# Confirmação de segurança
confirm_production() {
    echo -e "${YELLOW}"
    echo "⚠️  CONFIRMAÇÃO DE SEGURANÇA ⚠️"
    echo ""
    echo "Você está prestes a executar a release em PRODUÇÃO."
    echo "Esta operação irá:"
    echo "  • Parar o App Pool do OBT"
    echo "  • Limpar pastas ArgoWeb e TmsWeb"
    echo "  • Fazer backup da versão atual"
    echo "  • Instalar nova versão"
    echo "  • Reiniciar serviços"
    echo ""
    echo "CERTIFIQUE-SE DE QUE:"
    echo "  ✅ Teste foi executado na VM de DEV"
    echo "  ✅ Backup manual foi feito"
    echo "  ✅ Equipe foi notificada"
    echo "  ✅ Janela de manutenção está ativa"
    echo ""
    echo -e "${NC}"
    
    read -p "Digite 'CONFIRMO' para continuar: " confirmation
    if [[ "$confirmation" != "CONFIRMO" ]]; then
        log_error "Release cancelada pelo usuário"
        exit 1
    fi
    
    log_prod "Confirmação recebida. Iniciando release..."
}

# Verificar pré-requisitos
check_prerequisites() {
    log_prod "Verificando pré-requisitos para produção..."
    
    # Verificar se vault existe
    if [[ ! -f "$ANSIBLE_DIR/inventories/prd/vault.yml" ]]; then
        log_error "Arquivo vault.yml não encontrado para produção!"
        log_info "Crie o arquivo com: ansible-vault create $ANSIBLE_DIR/inventories/prd/vault.yml"
        exit 1
    fi
    
    # Verificar se senha do vault está disponível
    if [[ ! -f ".vault_pass" ]]; then
        log_warning "Arquivo .vault_pass não encontrado"
        log_info "Você precisará digitar a senha do vault durante a execução"
    fi
    
    # Verificar conectividade
    log_prod "Testando conectividade com produção..."
    cd "$ANSIBLE_DIR"
    
    if [[ -f "../.vault_pass" ]]; then
        ansible prd -m win_ping --vault-password-file ../.vault_pass > /dev/null 2>&1
    else
        ansible prd -m win_ping --ask-vault-pass > /dev/null 2>&1
    fi
    
    if [[ $? -eq 0 ]]; then
        log_success "✅ Conectividade com produção OK"
    else
        log_error "❌ Falha na conectividade com produção"
        exit 1
    fi
    
    log_success "Pré-requisitos verificados"
}

# Executar release
run_release() {
    local dry_run="$1"
    local verbose="$2"
    
    log_prod "Executando release em produção..."
    
    # Construir comando
    local cmd=(
        "ansible-playbook"
        "-i" "inventories/prd/hosts.yml"
        "playbooks/obt_release.yml"
        "--extra-vars" "environment=prd"
    )
    
    # Adicionar vault
    if [[ -f "../.vault_pass" ]]; then
        cmd+=("--vault-password-file" "../.vault_pass")
    else
        cmd+=("--ask-vault-pass")
    fi
    
    # Adicionar opções
    if [[ "$dry_run" == "true" ]]; then
        cmd+=("--check")
        log_warning "🧪 Executando em modo DRY-RUN (sem alterações)"
    fi
    
    if [[ "$verbose" == "true" ]]; then
        cmd+=("-v")
    fi
    
    log_prod "Comando: ${cmd[*]}"
    
    # Executar
    cd "$ANSIBLE_DIR"
    "${cmd[@]}"
}

# Função de ajuda
show_help() {
    cat << EOF
🚀 Script de Release em Produção

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Mostrar esta ajuda
    -v, --verbose           Log detalhado
    -d, --dry-run          Executar sem fazer alterações (RECOMENDADO primeiro)
    --no-confirm           Pular confirmação (USE COM CUIDADO!)

EXAMPLES:
    $0 --dry-run           # Teste em produção sem alterações
    $0                     # Release real (com confirmação)
    $0 --verbose           # Release com logs detalhados
    
IMPORTANTE:
    • SEMPRE execute --dry-run primeiro
    • Certifique-se de que o teste na VM foi bem-sucedido
    • Tenha backup manual antes da execução
    • Execute durante janela de manutenção
EOF
}

# Função principal
main() {
    local dry_run=false
    local verbose=false
    local no_confirm=false
    
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
            --no-confirm)
                no_confirm=true
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
    
    # Confirmação (exceto em dry-run)
    if [[ "$dry_run" == "false" && "$no_confirm" == "false" ]]; then
        confirm_production
    fi
    
    # Verificar pré-requisitos
    check_prerequisites
    
    # Executar release
    if run_release "$dry_run" "$verbose"; then
        echo -e "${GREEN}"
        echo "=========================================="
        echo "🎉 RELEASE CONCLUÍDA COM SUCESSO!"
        echo "=========================================="
        echo "✅ Release executada em produção"
        echo "📅 Concluída em: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "🔍 PRÓXIMOS PASSOS:"
        echo "  • Verificar funcionamento da aplicação"
        echo "  • Monitorar logs de erro"
        echo "  • Notificar equipe sobre conclusão"
        echo "=========================================="
        echo -e "${NC}"
        
    else
        echo -e "${RED}"
        echo "=========================================="
        echo "❌ RELEASE FALHOU!"
        echo "=========================================="
        echo "❌ Verifique os logs acima para detalhes"
        echo "🔄 Execute rollback se necessário"
        echo "📞 Notifique equipe sobre falha"
        echo "=========================================="
        echo -e "${NC}"
        exit 1
    fi
}

# Executar função principal
main "$@"
