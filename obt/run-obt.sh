#!/bin/bash

# ==========================================
# 🚀 EXECUTAR OBT RELEASE
# ==========================================
# Script para executar a automação OBT
# com configurações corretas
# ==========================================

set -e

echo "🚀 OBT Release Automation"
echo "========================="

# Entrar no diretório ansible
cd ansible

# Configurar variáveis de ambiente
export ANSIBLE_ROLES_PATH="$(pwd)/roles"
export ANSIBLE_HOST_KEY_CHECKING="False"
export ANSIBLE_DEPRECATION_WARNINGS="False"
export ANSIBLE_STDOUT_CALLBACK="default"

echo "📁 Diretório: $(pwd)"
echo "🎯 Roles path: $ANSIBLE_ROLES_PATH"
echo ""

# Verificar argumentos
DRY_RUN=""
VERBOSE=""
TAGS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|--check)
            DRY_RUN="--check"
            echo "🧪 Modo DRY-RUN ativado (sem alterações)"
            shift
            ;;
        -v|--verbose)
            VERBOSE="-v"
            echo "📝 Modo verbose ativado"
            shift
            ;;
        --tags)
            TAGS="--tags $2"
            echo "🏷️ Tags: $2"
            shift 2
            ;;
        -h|--help)
            echo "Uso: $0 [--dry-run] [--verbose] [--tags TAG1,TAG2]"
            echo ""
            echo "Opções:"
            echo "  --dry-run    Executar sem fazer alterações"
            echo "  --verbose    Logs detalhados"
            echo "  --tags       Executar apenas tags específicas"
            echo ""
            echo "Exemplos:"
            echo "  $0                    # Execução normal"
            echo "  $0 --dry-run         # Teste sem alterações"
            echo "  $0 --tags cleanup    # Apenas limpeza"
            exit 0
            ;;
        *)
            echo "❌ Opção desconhecida: $1"
            echo "Use --help para ver as opções disponíveis"
            exit 1
            ;;
    esac
done

# Teste de conectividade primeiro
echo "🌐 Testando conectividade..."
if ansible dev -i inventories/dev/hosts.yml -m win_ping > /dev/null 2>&1; then
    echo "✅ Conectividade OK"
else
    echo "❌ Falha na conectividade com a VM"
    echo "Verifique se a VM 10.60.7.11 está acessível"
    exit 1
fi

# Verificar sintaxe
echo "🔍 Verificando sintaxe..."
if ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --syntax-check > /dev/null 2>&1; then
    echo "✅ Sintaxe OK"
else
    echo "❌ Erro de sintaxe no playbook"
    ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --syntax-check
    exit 1
fi

# Construir comando
CMD="ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml"

if [[ -n "$DRY_RUN" ]]; then
    CMD="$CMD $DRY_RUN"
fi

if [[ -n "$VERBOSE" ]]; then
    CMD="$CMD $VERBOSE"
fi

if [[ -n "$TAGS" ]]; then
    CMD="$CMD $TAGS"
fi

echo ""
echo "🚀 Executando automação OBT..."
echo "📋 Comando: $CMD"
echo ""

# Executar
eval $CMD

echo ""
echo "🎉 Automação concluída!"
echo ""
