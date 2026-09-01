# Oficina API — Tech Challenge (Fase 1)

Back-end monolítico em **Ruby on Rails 8** para o Sistema Integrado de Atendimento e Execução de Serviços de uma oficina mecânica. O MVP cobre gestão de clientes, veículos, catálogo de serviços, peças/insumos com estoque e o ciclo de vida da **ordem de serviço (OS)**, com orçamento automático e aprovação pelo cliente.

## Objetivos

- Identificar o cliente por CPF/CNPJ e cadastrar o veículo (placa, marca, modelo, ano).
- Montar a OS com serviços e peças; calcular o orçamento automaticamente.
- Acompanhar o status da OS: Recebida → Em diagnóstico → Aguardando aprovação → Em execução → Finalizada → Entregue.
- Expor API pública para o cliente consultar progresso e autorizar/rejeitar o orçamento.
- Proteger APIs administrativas com JWT.
- Documentar a API (Swagger) e executar o ambiente com Docker.

## Documentação DDD e diagramas

Linguagem ubíqua, bounded contexts, agregado da OS, Event Storming e máquina de status estão no Miro:

**[Diagramas DDD — Miro](https://miro.com/app/board/uXjVHsDM-SM=/?share_link_id=386665499309)**

## Por que PostgreSQL?

O domínio é relacional (cliente, veículo, OS, itens, estoque) e exige:

- integridade referencial (foreign keys) para não perder histórico;
- transações ACID no débito de estoque na aprovação do orçamento;
- índices únicos em CPF/CNPJ, placa, SKU e token público da OS.

PostgreSQL é maduro, bem suportado pelo Rails e adequado a um monolito MVP, com caminho claro para crescer (JSON, relatórios, réplicas).

## Arquitetura em camadas (DDD leve)

| Camada | Pasta | Responsabilidade |
| --- | --- | --- |
| Domínio | `app/lib/domain` | Regras puras: CPF/CNPJ, placa, máquina de status, orçamento, estoque |
| Aplicação | `app/lib/use_cases` | Casos de uso (criar OS, enviar orçamento, aprovar, finalizar) |
| Infra | `app/models`, `db` | Persistência ActiveRecord |
| Interface | `app/controllers`, `app/serializers` | HTTP REST + JWT |

## Requisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (inclui Docker Compose)
- Git

Para rodar sem container (opcional): Ruby 3.3.6, PostgreSQL 16 e Bundler. Copie `.env.example` para `.env` e ajuste as variáveis.

## Primeira execução (Docker)

### 1. Clonar o repositório

```bash
git clone https://github.com/derektsc/Oficina-Tech-Challenge.git
cd Oficina-Tech-Challenge
```

### 2. Subir os containers

```bash
docker compose up --build
```

Na **primeira** subida, o build da imagem pode levar alguns minutos. O entrypoint executa `db:prepare` automaticamente (cria o banco e roda as migrations). Aguarde até ver algo como `Listening on http://0.0.0.0:3000` nos logs.

> **Windows:** o projeto usa bind mount (`.:app`). O entrypoint corrige CRLF nos scripts `bin/*` na subida — não é necessário alterar nada manualmente.

### 3. Carregar dados de demonstração

Com os containers rodando, em **outro terminal**:

```bash
docker compose exec app bundle exec rails db:seed
```

Isso cria o usuário admin, um cliente, veículo, serviços do catálogo e peças com estoque.

### 4. Validar que está funcionando

| Recurso | URL |
| --- | --- |
| API | http://localhost:3000 |
| Swagger (documentação interativa) | http://localhost:3000/api-docs |
| Healthcheck | http://localhost:3000/up |

No Swagger, faça login em `POST /api/v1/auth/login` com as credenciais abaixo e use o token retornado no botão **Authorize** (formato: `Bearer <token>`).

### Credenciais de seed

| Campo | Valor |
| --- | --- |
| E-mail | `admin@oficina.test` |
| Senha | `oficina123` |

### Comandos úteis no dia a dia

```bash
# Parar os containers
docker compose down

# Parar e remover volumes (reset completo do banco)
docker compose down -v

# Ver logs da aplicação
docker compose logs -f app
```

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

## Estrutura de pastas relevante

```
app/lib/domain       regras de negócio
app/lib/use_cases    orquestração dos fluxos
app/models           persistência
app/controllers      API REST
swagger/v1           OpenAPI
```
