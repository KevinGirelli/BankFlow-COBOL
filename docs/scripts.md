# Automation Scripts – BankFlow COBOL

## Overview (English)

The `scripts/` directory provides repeatable workflows for building, running, testing, linting, and migrating the application.

## Visão Geral (Português)

O diretório `scripts/` oferece fluxos reprodutíveis para compilar, executar, testar, aplicar lint e migrar a aplicação.

---

## Core Scripts

### `build.sh`
- **English:** Invokes `cobc` with free-format, warning flags, and include paths for copybooks/sections.
- **Português:** Invoca `cobc` com formato livre, flags de aviso e include paths para copybooks/sections.

### `run.sh`
- **English:** Ensures data/report/log directories exist, builds if necessary, exports env vars, and launches the program.
- **Português:** Garante a existência dos diretórios de dados/relatórios/logs, compila quando necessário, exporta variáveis de ambiente e executa o programa.

### `reset-data.sh`
- **English:** Clears sequential data (`clients.dat`, `accounts.dat`, `transactions.dat`) and report/log outputs; accepts custom directories.
- **Português:** Limpa os arquivos sequenciais (`clients.dat`, `accounts.dat`, `transactions.dat`) e saídas de relatório/log, aceitando diretórios customizados.

### `lint.sh`
- **English:** Runs `cobc -fsyntax-only` with strict warnings to catch syntax issues early.
- **Português:** Executa `cobc -fsyntax-only` com avisos rigorosos para detectar problemas de sintaxe.

### `test.sh`
- **English:** Builds the binary, resets isolated data directories, executes scripted interactions, validates log/report output, and preserves artifacts.
- **Português:** Compila o binário, reinicia diretórios isolados de dados, executa interações roteirizadas, valida logs/relatórios e preserva artefatos.

---

## Migration Scripts

### `migrate_to_sqlite.py`
- **English:** Parses sequential files using fixed-length layouts and populates `migrations/bankflow.sqlite`. Supports custom data directories and schema reset.
- **Português:** Analisa os arquivos sequenciais com layouts de comprimento fixo e popula `migrations/bankflow.sqlite`. Suporta diretórios de dados personalizados e reinicialização de esquema.

### `migrate_from_sqlite.py`
- **English:** Reads the SQLite database, validates record lengths, and regenerates `.dat` files in the chosen directory (optionally overwriting existing files).
- **Português:** Lê o banco SQLite, valida comprimentos de registro e regenera os arquivos `.dat` no diretório escolhido (opcionalmente sobrescrevendo arquivos existentes).

---

## Usage Tips (English)

- Set `DATA_DIR`, `REPORT_DIR`, `LOG_DIR`, or `BANKFLOW_DATA_DIR` when running scripts in CI.
- Preserve generated artifacts (`migrations/bankflow.sqlite`, logs) for debugging failed runs.

## Dicas de Uso (Português)

- Defina `DATA_DIR`, `REPORT_DIR`, `LOG_DIR` ou `BANKFLOW_DATA_DIR` ao executar scripts em CI.
- Preserve artefatos gerados (`migrations/bankflow.sqlite`, logs) para depurar execuções falhas.

