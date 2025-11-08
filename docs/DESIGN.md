# BankFlow COBOL – Design Overview

## English

### Purpose

BankFlow COBOL demonstrates how a sequential-file banking workload can be organised in modern GnuCOBOL while remaining compatible with legacy environments.

### Architecture

- `src/app/BankFlow.cbl` – main program that copies each division.
- `src/copybooks/`
  - `file-control.cpy` – `SELECT` clauses with dynamic path resolution.
  - `file-section.cpy` – FD/01 layouts for every physical file.
  - `working-storage.cpy` – shared constants, status fields, and runtime tables.
- `src/sections/main-section.cpy` – orchestrator that pulls specialised sections:
  - `index-section.cpy` – in-memory caches for customers and accounts.
  - `logging-section.cpy` – structured logging routines.
  - `initialization-section.cpy` – environment discovery and file provisioning.
  - `menu-section.cpy` – interactive loop and option routing.
  - `client-section.cpy` – customer registration and validation.
  - `account-section.cpy` – account lifecycle, deposits, withdrawals, transfers, balance checks.
  - `report-section.cpy` – activity report generation and summarisation.
  - `utility-section.cpy` – shared helpers (timestamp builder, transaction writer).
  - `finalize-section.cpy` – graceful shutdown and log closure.
  - `entry-section.cpy` – ties initialisation, menu, and finalisation together.
- `data/` – sequential datasets (`clients.dat`, `accounts.dat`, `transactions.dat`).
- `reports/` – generated reports (`report.txt`).
- `scripts/` – automation (build, run, reset, lint, tests, migrations).

### Execution Flow

```
BankFlow.cbl
 └── main-section.cpy
      ├── index-section.cpy
      ├── logging-section.cpy
      ├── initialization-section.cpy
      ├── menu-section.cpy
      ├── client-section.cpy
      ├── account-section.cpy
      ├── report-section.cpy
      ├── utility-section.cpy
      ├── finalize-section.cpy
      └── entry-section.cpy
```

1. **Initialisation** – resolve directories, build dynamic paths, ensure files exist.
2. **Menu loop** – display options, accept user input, dispatch via `EVALUATE`.
3. **Domain logic**
   - Customers: sanitise CPF, prevent duplicates, update caches.
   - Accounts: bind to customers, maintain balances, synchronise caches.
   - Transactions: validate operations, persist entries with timestamps.
   - Reports: stream transactions, render accounts, compute aggregated totals.
4. **Utilities** – consistent timestamp formatting, structured logging, migration helpers.

### Utilities & Reliability

- `scripts/migrate_to_sqlite.py` / `migrate_from_sqlite.py` support round-tripping data between sequential files and SQLite.
- The `migrations/` directory stores generated databases while avoiding binary noise in version control.
- Structured logging and verbose mode aid troubleshooting in both interactive runs and automated tests.
- Utility metrics capture session duration and operation outcomes, logging a summary before shutdown.

### Conventions

- Free source format (`>>SOURCE FORMAT FREE`).
- Section delimiters using `*> START ... / *> END ...`.
- Paragraph names are uppercase verbs for readability.
- User messages always accompany status information on errors.

### Next Steps

- Explore indexed files or lightweight relational storage using the existing migration tooling.
- Add sequence diagrams for critical operations (e.g., withdrawal, report generation).
- Capture additional observability signals (I/O timing, cache statistics).

---

## Português

### Objetivo

BankFlow COBOL demonstra como organizar um domínio bancário baseado em arquivos sequenciais em GnuCOBOL moderno, mantendo compatibilidade com ambientes legados.

### Arquitetura

- `src/app/BankFlow.cbl` – programa principal que inclui cada divisão.
- `src/copybooks/`
  - `file-control.cpy` – cláusulas `SELECT` com resolução dinâmica de caminhos.
  - `file-section.cpy` – layouts FD/01 de cada arquivo físico.
  - `working-storage.cpy` – constantes compartilhadas, status e tabelas em memória.
- `src/sections/main-section.cpy` – orquestrador que reúne seções especializadas:
  - `index-section.cpy` – caches em memória para clientes e contas.
  - `logging-section.cpy` – rotinas de logging estruturado.
  - `initialization-section.cpy` – descoberta de ambiente e preparação de arquivos.
  - `menu-section.cpy` – laço interativo e roteamento de opções.
  - `client-section.cpy` – cadastro e validação de clientes.
  - `account-section.cpy` – ciclo de vida da conta, depósitos, saques, transferências e saldos.
  - `report-section.cpy` – geração de relatórios e sumarização.
  - `utility-section.cpy` – utilitários compartilhados (construtor de timestamp, gravação de transações).
  - `finalize-section.cpy` – encerramento elegante e fechamento de logs.
  - `entry-section.cpy` – conecta inicialização, menu e finalização.
- `data/` – conjuntos sequenciais (`clients.dat`, `accounts.dat`, `transactions.dat`).
- `reports/` – relatórios gerados (`report.txt`).
- `scripts/` – automação (build, execução, limpeza, lint, testes, migrações).

### Fluxo de Execução

```
BankFlow.cbl
 └── main-section.cpy
      ├── index-section.cpy
      ├── logging-section.cpy
      ├── initialization-section.cpy
      ├── menu-section.cpy
      ├── client-section.cpy
      ├── account-section.cpy
      ├── report-section.cpy
      ├── utility-section.cpy
      ├── finalize-section.cpy
      └── entry-section.cpy
```

1. **Inicialização** – resolve diretórios, monta caminhos dinâmicos e garante a existência dos arquivos.
2. **Laço do menu** – exibe opções, aceita entradas e despacha via `EVALUATE`.
3. **Lógica de domínio**
   - Clientes: higieniza CPF, evita duplicidades e atualiza caches.
   - Contas: vincula ao cliente, mantém saldos e sincroniza caches.
   - Transações: valida operações, persiste registros com timestamp.
   - Relatórios: percorre transações, apresenta contas e calcula totais agregados.
4. **Utilitários** – formatação consistente de timestamp, logging estruturado e auxiliares de migração.

### Utilitários & Confiabilidade

- `scripts/migrate_to_sqlite.py` e `migrate_from_sqlite.py` permitem ida e volta entre arquivos sequenciais e SQLite.
- O diretório `migrations/` armazena bancos gerados, evitando ruído binário no controle de versão.
- Logs estruturados e modo verboso auxiliam na depuração em execuções interativas e testes automatizados.
- Métricas utilitárias capturam a duração da sessão e o resultado das operações, registrando um resumo antes do encerramento.

### Convenções

- Formato livre de código (`>>SOURCE FORMAT FREE`).
- Delimitadores de seção com `*> START ... / *> END ...`.
- Nomes de parágrafos em maiúsculas com verbos descritivos.
- Mensagens ao usuário sempre acompanham informações de status em casos de erro.

### Próximos Passos

- Explorar arquivos indexados ou armazenamento relacional leve reutilizando as ferramentas de migração.
- Adicionar diagramas de sequência para operações críticas (ex.: saque, geração de relatório).
- Capturar métricas adicionais de observabilidade (tempo de I/O, estatísticas dos caches).

