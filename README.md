# Oficina API - Tech Challenge (MVP)

Back-end monolítico em **Ruby on Rails 8** para o Sistema Integrado de Atendimento e Execução de Serviços de uma oficina mecânica. O MVP cobre gestão de clientes, veículos, catálogo de serviços, peças/insumos com estoque e o ciclo de vida da **ordem de serviço (OS)**, com orçamento automático e aprovação pelo cliente.

## Objetivos

- Identificar o cliente por CPF/CNPJ e cadastrar o veículo (placa, marca, modelo, ano).
- Montar a OS com serviços e peças; calcular o orçamento automaticamente.
- Acompanhar o status da OS: Recebida → Em diagnóstico → Aguardando aprovação → Em execução → Finalizada → Entregue.
- Expor API pública para o cliente consultar progresso e autorizar/rejeitar o orçamento.
- Proteger APIs administrativas com JWT.
- Documentar a API (Swagger) e executar o ambiente com Docker.

## Por que PostgreSQL?

Foi escolhido o **PostgreSQL** porque o domínio é relacional (cliente, veículo, OS, itens, estoque) e exige:

- integridade referencial (foreign keys) para não perder histórico;
- transações ACID no débito de estoque na aprovação do orçamento;
- índices únicos em CPF/CNPJ, placa, SKU e token público da OS.

É um banco maduro, bem suportado pelo Rails e adequado a um monolito MVP, com caminho claro para crescer (JSON, relatórios, réplicas).

## Arquitetura em camadas (DDD leve)

| Camada | Pasta | Responsabilidade |
| --- | --- | --- |
| Domínio | `app/lib/domain` | Regras puras: CPF/CNPJ, placa, máquina de status, orçamento, estoque |
| Aplicação | `app/lib/use_cases` | Casos de uso (criar OS, enviar orçamento, aprovar, finalizar) |
| Infra | `app/models`, `db` | Persistência ActiveRecord |
| Interface | `app/controllers`, `app/serializers` | HTTP REST + JWT |

Documentação DDD (linguagem ubíqua, bounded contexts e event storming): [`docs/ddd.md`](docs/ddd.md).

## Requisitos

- Docker e Docker Compose
- (Opcional) Ruby 3.3.6 e PostgreSQL 16 para execução sem container

## Execução local (Docker)

```bash
docker compose up --build
```

Na primeira subida o entrypoint executa `db:prepare`. Depois, carregue os dados de demonstração:

```bash
docker compose exec app bundle exec rails db:seed
```

- API: http://localhost:3000
- Swagger: http://localhost:3000/api-docs
- Healthcheck: http://localhost:3000/up

### Credenciais de seed

- E-mail: `admin@oficina.test`
- Senha: `oficina123`

## Fluxo rápido da OS

1. `POST /api/v1/auth/login` → obter JWT.
2. `POST /api/v1/admin/service_orders` com cliente (CPF), veículo e itens.
3. `POST /api/v1/admin/service_orders/:id/start_diagnosis`
4. `POST /api/v1/admin/service_orders/:id/send_budget`
5. Cliente consulta `GET /api/v1/public/service_orders/:public_token`
6. Cliente aprova `POST /api/v1/public/service_orders/:public_token/approve` (debita estoque)
7. Oficina finaliza e entrega: `.../finish` e `.../deliver`
8. Métrica: `GET /api/v1/admin/metrics/average_execution_time`

Todas as rotas `/api/v1/admin/*` exigem `Authorization: Bearer <token>`.

## Testes

```bash
docker compose --profile test run --rm test
```

A suíte usa RSpec + SimpleCov (meta mínima de 80% nos arquivos instrumentados).

## Segurança

```bash
docker compose run --rm --no-deps app bundle exec brakeman -q
docker compose run --rm --no-deps app bundle exec bundle-audit check --update
```

Relatório da análise: [`docs/vulnerabilidades.md`](docs/vulnerabilidades.md).

## Entrega acadêmica

O enunciado pede repositório **privado** com acesso ao usuário GitHub `soat-architecture`, vídeo de até 15 minutos, documentação DDD (Miro ou equivalente) e PDF de entrega com participantes. Este código cobre o backend, Docker, Swagger, testes e a base da documentação DDD.

## Estrutura de pastas relevante

```
app/lib/domain       regras de negócio
app/lib/use_cases    orquestração dos fluxos
app/models          persistência
app/controllers     API REST
swagger/v1          OpenAPI
docs                DDD e segurança
```
