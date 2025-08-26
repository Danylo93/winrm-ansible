#!/bin/bash

ansible-playbook -i inventory_win.yml obt_release.yml &&
echo "Aguardando 10s..." && sleep 10 &&
curl -X POST https://dev.azure.com/ORG/PROJECT/_apis/pipelines/ID/runs?api-version=7.0 \
  -H "Authorization: Basic <token>" \
  -H "Content-Type: application/json" \
  -d '{ "resources": { "repositories": { "self": { "refName": "refs/heads/main" }}}}'
