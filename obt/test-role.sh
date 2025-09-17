#!/bin/bash
# ==========================================
# 🎭 TESTE DE VALIDAÇÃO DA ROLE
# ==========================================

cd ansible

echo "🎭 Validando estrutura da role OBT..."

# Verificar se role tem estrutura correta
role_dirs=("tasks" "defaults" "meta" "handlers" "vars" "templates")
for dir in "${role_dirs[@]}"; do
  if [ ! -d "roles/obt_release/$dir" ]; then
    echo "❌ Diretório da role não encontrado: roles/obt_release/$dir"
    exit 1
  else
    echo "✅ Diretório encontrado: roles/obt_release/$dir"
  fi
done

# Verificar arquivos obrigatórios
required_files=(
  "roles/obt_release/tasks/main.yml"
  "roles/obt_release/defaults/main.yml"
  "roles/obt_release/meta/main.yml"
  "roles/obt_release/handlers/main.yml"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    echo "❌ Arquivo obrigatório não encontrado: $file"
    exit 1
  else
    echo "✅ Arquivo encontrado: $file"
  fi
done

echo ""
echo "🎉 Role OBT validada com sucesso!"
echo "✅ Todos os diretórios obrigatórios presentes"
echo "✅ Todos os arquivos obrigatórios presentes"
echo "✅ Estrutura da role está correta"
