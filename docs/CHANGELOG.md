# Changelog

## English

### 2025-11-08

- Major restructuring:
  - Main program consolidated in `src/app/BankFlow.cbl` with dedicated copybooks and sections.
  - Standardised directories (`data/`, `reports/`, `build/`, `scripts/`, `docs/`).
  - File definitions and working-storage moved into `src/copybooks/`.
  - Procedures organised into themed sections under `src/sections/`.
- Validation improvements:
  - CPF sanitised and checked for duplicates.
  - Numeric inputs (accounts, amounts) validated with clear feedback.
  - Transactions recorded with formatted timestamps.
- Reporting updates:
  - Activity report generated in `reports/report.txt` with a consistent header.
  - Aggregated customer balance displayed.
- Automation scripts (`build.sh`, `run.sh`, `reset-data.sh`) streamline compilation, execution, and cleanup.
- Tooling additions:
  - `lint.sh` performs syntax checks with configured include paths.
  - `test.sh` drives end-to-end scenarios and captures logs.
  - `.gitignore` covers build outputs, data, reports, and logs.
- In-memory indexing:
  - Runtime caches map CPF→customer ID and account→(customer, balance).
  - Caches update automatically after registration, deposits, or withdrawals with seamless fallbacks.
  - Architecture documented in `docs/indexing.md`.
- Observability:
  - Structured logs (`logs/events.log`) include timestamp, type, and status.
  - Verbose mode enabled via `BANKFLOW_VERBOSE`/`VERBOSE` and configurable path (`BANKFLOW_LOG_FILE`).
  - Test suite extended with negative scenarios and log/report verification.
- Migration tooling:
  - `migrate_to_sqlite.py` and `migrate_from_sqlite.py` export and restore sequential data to/from SQLite.
  - `migrations/` tracked with `.gitkeep` and ignored binaries.
  - Detailed guidance in `docs/migration.md`.

---

## Português

### 2025-11-08

- Reestruturação completa do projeto:
  - Programa principal consolidado em `src/app/BankFlow.cbl` com copybooks e sections dedicados.
  - Diretórios padronizados (`data/`, `reports/`, `build/`, `scripts/`, `docs/`).
  - Definições de arquivos e working-storage movidas para `src/copybooks/`.
  - Procedimentos organizados em seções temáticas dentro de `src/sections/`.
- Melhorias de validação:
  - CPF higienizado e verificado quanto a duplicidades.
  - Entradas numéricas (contas, valores) validadas com mensagens claras.
  - Transações registradas com carimbo de data/hora formatado.
- Atualizações de relatórios:
  - Relatório de movimentações gerado em `reports/report.txt` com cabeçalho consistente.
  - Exibição do saldo total agregado por cliente.
- Scripts de automação (`build.sh`, `run.sh`, `reset-data.sh`) agilizam compilação, execução e limpeza.
- Novas ferramentas:
  - `lint.sh` realiza checagens de sintaxe com paths configurados.
  - `test.sh` automatiza cenários ponta a ponta e captura logs.
  - `.gitignore` cobre artefatos de build, dados, relatórios e logs.
- Indexação em memória:
  - Caches carregadas em tempo de execução mapeiam CPF→ID de cliente e conta→(cliente, saldo).
  - Atualização automática após cadastro, depósitos ou saques, com fallback transparente.
  - Detalhes documentados em `docs/indexing.md`.
- Observabilidade:
  - Logs estruturados (`logs/events.log`) incluem timestamp, tipo e status.
  - Modo verboso via `BANKFLOW_VERBOSE`/`VERBOSE` e caminho configurável (`BANKFLOW_LOG_FILE`).
  - Suite de testes ampliada com cenários negativos e validação de logs/relatórios.
- Ferramentas de migração:
  - `migrate_to_sqlite.py` e `migrate_from_sqlite.py` exportam e restauram dados sequenciais em SQLite.
  - Diretório `migrations/` versionado com `.gitkeep` e binários ignorados.
  - Orientações detalhadas em `docs/migration.md`.

