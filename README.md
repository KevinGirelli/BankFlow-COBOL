# BankFlow COBOL

## English

### Overview

BankFlow COBOL is an educational current-account simulator that stores customers, accounts, and transactions in sequential files. The codebase illustrates maintainable COBOL practices, consistent validation, and a migration path toward indexed or relational storage.

### Directory Structure

- `src/`
  - `app/BankFlow.cbl` – program entry point that copies each division.
  - `copybooks/` – shared file definitions and working-storage structures.
  - `sections/` – reusable procedure sections separated by responsibility.
- `data/` – persistent sequential files (`clients.dat`, `accounts.dat`, `transactions.dat`).
- `reports/` – generated reports (`report.txt`).
- `build/` – compilation output (`bankflow` binary and objects).
- `scripts/` – automation helpers (`build.sh`, `run.sh`, `reset-data.sh`, `lint.sh`, `test.sh`, `migrate_to_sqlite.py`, `migrate_from_sqlite.py`).
- `migrations/` – optional export artifacts such as `bankflow.sqlite`.
- `docs/` – design notes, changelog, indexing strategy, and component guides.

All paths default to these folders but can be overridden with environment variables.

### Current Features

- Customer registration with CPF validation and duplicate detection.
- Account creation linked to existing customers with sequential numbering.
- Deposits and withdrawals with robust validation and transaction logging.
- Balance inquiry with readable formatting.
- Activity report written to `reports/report.txt`, including aggregated customer balance.
- Structured event logging (`logs/events.log`) with optional verbose mode.
- In-memory caches for customers and accounts to accelerate lookups.

### Usage

```bash
# Build the executable into build/bankflow
./scripts/build.sh

# Run the program (uses data/ and reports/ by default)
./scripts/run.sh

# Syntax/lint check
./scripts/lint.sh

# Automated functional tests
./scripts/test.sh

# Export sequential files to SQLite
./scripts/migrate_to_sqlite.py --reset

# Recreate sequential files from SQLite
./scripts/migrate_from_sqlite.py --sqlite-path migrations/bankflow.sqlite --out-dir data --overwrite
```

Environment variables allow custom locations:

```bash
DATA_DIR=/tmp/bankflow-data REPORT_DIR=/tmp/bankflow-reports LOG_DIR=/tmp/bankflow-logs VERBOSE=Y ./scripts/run.sh
BANKFLOW_LOG_FILE=/tmp/custom.log BANKFLOW_VERBOSE=Y ./scripts/run.sh
```

Reset to a clean state:

```bash
./scripts/reset-data.sh
```

### SQLite Migration

Use the migration helpers to mirror sequential data in SQLite without leaving the COBOL workflow:

```bash
# Create migrations/bankflow.sqlite (drops previous content)
./scripts/migrate_to_sqlite.py --reset

# Rebuild .dat files into a temporary directory
./scripts/migrate_from_sqlite.py --out-dir /tmp/bankflow-seq
```

- Both scripts honour `BANKFLOW_DATA_DIR` unless `--data-dir`/`--out-dir` is provided.
- Monetary values are stored as integer cents (`amount_cents`) for precision.
- `--overwrite` prevents accidental replacement unless explicitly requested.

### Suggested Improvements

- Extend operations (internal transfers, account closure) leveraging existing logging and indexing infrastructure.
- Expand observability with performance metrics (I/O timing, table sizes).
- Offer alternative front-ends (advanced TUI or REST facade).
- Automate lab deployments (e.g., container with GnuCOBOL and SQLite preloaded).

---

## Português

### Visão Geral

BankFlow COBOL é um simulador didático de contas correntes que armazena clientes, contas e transações em arquivos sequenciais. O código demonstra práticas de COBOL sustentáveis, validações consistentes e um caminho de migração para arquivos indexados ou bancos relacionais.

### Estrutura de Diretórios

- `src/`
  - `app/BankFlow.cbl` – ponto de entrada que inclui cada divisão.
  - `copybooks/` – definições compartilhadas de arquivos e working-storage.
  - `sections/` – seções reutilizáveis separadas por responsabilidade.
- `data/` – arquivos sequenciais persistentes (`clients.dat`, `accounts.dat`, `transactions.dat`).
- `reports/` – relatórios gerados (`report.txt`).
- `build/` – saída da compilação (binário `bankflow` e objetos).
- `scripts/` – utilitários de automação (`build.sh`, `run.sh`, `reset-data.sh`, `lint.sh`, `test.sh`, `migrate_to_sqlite.py`, `migrate_from_sqlite.py`).
- `migrations/` – artefatos opcionais de exportação como `bankflow.sqlite`.
- `docs/` – notas de design, changelog, estratégia de indexação e guias de componentes.

Todos os caminhos usam esses diretórios por padrão, mas podem ser sobrescritos via variáveis de ambiente.

### Funcionalidades Atuais

- Cadastro de clientes com validação de CPF e detecção de duplicidades.
- Criação de contas vinculadas a clientes existentes com numeração sequencial.
- Depósitos e saques com validações robustas e registro de transações.
- Consulta de saldo com formatação legível.
- Relatório de movimentações gravado em `reports/report.txt`, incluindo o saldo agregado do cliente.
- Logs estruturados (`logs/events.log`) com modo verboso opcional.
- Caches em memória de clientes e contas para acelerar buscas.

### Uso

```bash
# Compilar o executável em build/bankflow
./scripts/build.sh

# Executar o programa (usa data/ e reports/ por padrão)
./scripts/run.sh

# Verificar sintaxe/lint
./scripts/lint.sh

# Testes funcionais automatizados
./scripts/test.sh

# Exportar arquivos sequenciais para SQLite
./scripts/migrate_to_sqlite.py --reset

# Recriar arquivos sequenciais a partir do SQLite
./scripts/migrate_from_sqlite.py --sqlite-path migrations/bankflow.sqlite --out-dir data --overwrite
```

Variáveis de ambiente permitem personalizar os caminhos:

```bash
DATA_DIR=/tmp/bankflow-data REPORT_DIR=/tmp/bankflow-reports LOG_DIR=/tmp/bankflow-logs VERBOSE=Y ./scripts/run.sh
BANKFLOW_LOG_FILE=/tmp/custom.log BANKFLOW_VERBOSE=Y ./scripts/run.sh
```

Restaurar o estado inicial:

```bash
./scripts/reset-data.sh
```

### Migração SQLite

Utilize os utilitários de migração para espelhar os dados sequenciais em SQLite sem abandonar o fluxo COBOL:

```bash
# Criar migrations/bankflow.sqlite (descarta conteúdo anterior)
./scripts/migrate_to_sqlite.py --reset

# Regenerar arquivos .dat em um diretório temporário
./scripts/migrate_from_sqlite.py --out-dir /tmp/bankflow-seq
```

- Ambos os scripts respeitam `BANKFLOW_DATA_DIR`, salvo uso de `--data-dir`/`--out-dir`.
- Valores monetários são armazenados como centavos inteiros (`amount_cents`) para manter a precisão.
- `--overwrite` evita substituições acidentais, a menos que solicitadas explicitamente.

### Evoluções Sugeridas

- Ampliar as operações (transferências internas, encerramento de contas) reutilizando logs e índices existentes.
- Expandir a observabilidade com métricas de desempenho (tempo de I/O, tamanho das tabelas).
- Oferecer camadas de apresentação alternativas (TUI avançada ou fachada REST).
- Automatizar deploys para ambientes de laboratório (ex.: contêiner com GnuCOBOL e SQLite pré-carregado).

