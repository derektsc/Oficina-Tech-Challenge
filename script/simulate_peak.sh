#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:3000}"
COUNT="${COUNT:-20}"

login="$(curl -sf -X POST "$BASE_URL/api/v1/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"email":"admin@oficina.test","password":"oficina123"}')"
TOKEN="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["token"])' "$login")"

services="$(curl -sf -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/v1/admin/catalog_services")"
parts="$(curl -sf -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/v1/admin/parts")"
SERVICE_ID="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])[0]["id"])' "$services")"
PART_ID="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])[0]["id"])' "$parts")"

for i in $(seq 1 "$COUNT"); do
  curl -sf -X POST "$BASE_URL/api/v1/admin/service_orders" \
    -H "Authorization: Bearer $TOKEN" \
    -H 'Content-Type: application/json' \
    -d "{\"customer\":{\"name\":\"Pico $i\",\"document\":\"52998224725\",\"email\":\"maria@example.com\"},\"vehicle\":{\"plate\":\"ABC1D23\",\"brand\":\"Volkswagen\",\"model\":\"Gol\",\"year\":2020},\"items\":[{\"item_type\":\"service\",\"catalog_service_id\":$SERVICE_ID,\"quantity\":1},{\"item_type\":\"part\",\"part_id\":$PART_ID,\"quantity\":1}]}" \
    >/dev/null &
  if (( i % 8 == 0 )); then
    wait
  fi
done
wait

echo "Criadas $COUNT ordens de serviço em $BASE_URL"
curl -sf -H "Authorization: Bearer $TOKEN" "$BASE_URL/api/v1/admin/service_orders" \
  | python3 -c 'import json,sys; data=json.load(sys.stdin); print(len(data), "OS na fila operacional")'
