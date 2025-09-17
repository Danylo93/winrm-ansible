#!/bin/bash
# ==========================================
# 🔍 TESTE DE SINTAXE ANSIBLE
# ==========================================

cd ansible

export ANSIBLE_ROLES_PATH="$(pwd)/roles"
export ANSIBLE_HOST_KEY_CHECKING="False"
export ANSIBLE_DEPRECATION_WARNINGS="False"
export ANSIBLE_STDOUT_CALLBACK="default"

echo "🔍 Testando sintaxe do playbook..."
ansible-playbook -i inventories/dev/hosts.yml playbooks/obt_release.yml --syntax-check

if [ $? -eq 0 ]; then
    echo "✅ Sintaxe do playbook está correta!"
else
    echo "❌ Erro de sintaxe encontrado!"
    exit 1
fi
