# Oficina API - Tech Challenge (Fase 1)

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

**[Vídeo da Fase 1 — YouTube](https://www.youtube.com/watch?v=RyrMkk2pN3Q)**

Decisões de arquitetura, contexto de negócio e justificativas técnicas (incluindo persistência em PostgreSQL) estão no documento:

**[Grupo 110 — Fase 1 — Arquitetura de Software (PDF)](Grupo110-Fase1-Derek-TechChallenge-ArquiteturaSoftware.pdf)**

## Decisões de arquitetura — persistência (PostgreSQL)

### Contexto de negócio

O cenário do challenge descreve uma oficina que opera com planilhas e processos manuais. Isso gera problemas concretos que a persistência precisa resolver:

- **Perda de histórico:** uma OS ligada ao cliente e ao veículo deve permanecer consultável mesmo após a entrega — o dono pode voltar meses depois com o mesmo carro.
- **Concorrência no estoque:** quando o cliente aprova o orçamento, as peças são debitadas; duas aprovações simultâneas não podem consumir o mesmo item sem saldo.
- **Identificadores únicos no negócio:** CPF/CNPJ, placa, SKU e número da OS são chaves naturais do domínio — duplicatas quebram operação e auditoria.
- **Valores monetários confiáveis:** orçamento, preços de serviço e peças precisam de precisão decimal estável, sem erro de arredondamento.
- **Rastreabilidade do fluxo:** cada transição de status da OS (`received` → `delivered`) registra timestamps usados em métricas operacionais (ex.: tempo médio de execução).

Esses requisitos apontam a um modelo **fortemente relacional**, com **consistência transacional** e **restrições no banco**, não apenas validações na aplicação.

### Requisitos derivados para a camada de dados

| Requisito de negócio | Exigência técnica no banco |
| --- | --- |
| Cliente → veículos → OS → itens | Relacionamentos com foreign keys |
| Débito de estoque na aprovação | Transação ACID + lock de linha |
| Sem CPF/placa/SKU duplicado | Índices únicos |
| Orçamento correto em centavos | `DECIMAL`, não `FLOAT` |
| Consulta por status e documento | Índices em colunas de filtro |
| Histórico auditável da OS | Registros persistentes, sem “documento solto” |

### Alternativas consideradas

| Opção | Por que não foi escolhida |
| --- | --- |
| **SQLite** | Adequado para protótipo local, mas concorrência de escrita limitada. O fluxo de aprovação usa `Part.lock` e débito transacional — cenário sensível quando vários operadores e clientes interagem ao mesmo tempo. Não é o padrão de produção para APIs multiusuário. |
| **MySQL / MariaDB** | Viável tecnicamente, mas o ecossistema Rails + PostgreSQL é mais homogêneo (tipos, migrations, ferramentas). Para este MVP, o ganho de trocar não compensa o custo de divergir do stack mais comum em projetos Rails. |
| **MongoDB / NoSQL** | O domínio é relacional por natureza (agregado da OS referencia cliente, veículo, catálogo e peças). Modelar isso em documentos exige duplicação ou joins na aplicação, enfraquecendo integridade referencial e consistência de estoque. |
| **Redis / cache como fonte primária** | Excelente para cache ou filas, mas não substitui persistência durável e transacional do histórico de OS e movimentação de estoque. |

### Decisão: PostgreSQL 16

PostgreSQL atende os requisitos de negócio e técnicos do MVP com o menor risco para um monolito Rails.

**Fundamento de negócio**

- Garante que **uma OS nunca fica “órfã”**: foreign keys entre `customers`, `vehicles`, `service_orders` e `service_order_items` impedem apagar ou referenciar entidades inconsistentes — o histórico do cliente no negócio fica preservado.
- O débito de estoque na aprovação (`ApproveBudget`) roda dentro de `ActiveRecord::Base.transaction` com `Part.lock`: se o saldo não cobre a quantidade, a transação falha e **nem o status da OS nem o estoque ficam inconsistentes** — evita prometer um reparo sem peça disponível.
- Índices únicos em `document`, `plate`, `sku`, `number` e `public_token` espelham **regras operacionais da oficina** (um CPF, uma placa, um SKU, um número de OS).
- Timestamps (`execution_started_at`, `finished_at`, etc.) ficam no mesmo registro da OS, permitindo métricas como tempo médio de execução sem reconstruir histórico manualmente.

**Fundamento técnico**

- **ACID e locking:** suporte nativo a transações e `SELECT … FOR UPDATE` (usado via `lock` no ActiveRecord) para concorrência segura no estoque.
- **Integridade referencial:** constraints declaradas no schema (`add_foreign_key` em todas as relações do domínio).
- **Tipos adequados ao domínio:** `decimal(12,2)` para dinheiro; `string` com índices para identificadores de negócio.
- **Stack Rails:** adapter `postgresql` nativo, `db:prepare` no Docker, migrations e `schema.rb` versionados — onboarding e CI simples.
- **Evolução sem troca de banco:** JSONB para campos flexíveis futuros, views/materialized views para relatórios, réplicas de leitura e particionamento se a oficina escalar.

### Como isso aparece no código

```ruby
# Aprovação: transação + lock de linha antes do débito
ActiveRecord::Base.transaction do
  part = Part.lock.find(item.part_id)
  StockControl.new(part).debit!(item.quantity)
  order.transition_to!(Status::IN_EXECUTION)
end
```

No schema: FKs em todas as entidades do fluxo da OS, índice em `status` para listagens operacionais e unicidade nos identificadores de negócio.

### Trade-offs aceitos

- **Monolito com um banco:** simplicidade operacional no MVP; microserviços ou CQRS não são necessários na Fase 1.
- **PostgreSQL exige container/serviço dedicado:** custo mínimo de infra frente à robustez; o `docker-compose.yml` já provisiona `postgres:16-alpine` com volume persistente.
- **Modelo normalizado:** joins em consultas, mas consistência e auditoria superam a conveniência de documentos aninhados para este domínio.

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
