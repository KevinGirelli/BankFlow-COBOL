# Automation Scripts – BankFlow COBOL

## English

### Overview

The `scripts/` directory provides repeatable workflows for building, running, testing, linting, and migrating the application.

### Core Scripts

- `build.sh`: Invokes `cobc` with free-format, warning flags, and include paths for copybooks/sections.
- `run.sh`: Ensures data/report/log directories exist, builds if necessary, exports environment variables, and launches the program.
- `reset-data.sh`: Clears sequential data (`clients.dat`, `accounts.dat`, `transactions.dat`) and report/log outputs; accepts custom directories.
- `lint.sh`: Runs `cobc -fsyntax-only` with strict warnings to catch syntax issues early.
- `test.sh`: Builds the binary, resets isolated data directories, executes scripted interactions, validates log/report output, and preserves artifacts.

### Migration Scripts

- `migrate_to_sqlite.py`: Parses sequential files using fixed-length layouts and populates `migrations/bankflow.sqlite`. Supports custom data directories and schema reset.
- `migrate_from_sqlite.py`: Reads the SQLite database, validates record lengths, and regenerates `.dat` files in the chosen directory (optionally overwriting existing files).

### Usage Tips

- Set `DATA_DIR`, `REPORT_DIR`, `LOG_DIR`, or `BANKFLOW_DATA_DIR` when running scripts in CI.
- Preserve generated artifacts (`migrations/bankflow.sqlite`, logs) for debugging failed runs.

---

## Português

### Visão Geral

O diretório `scripts/` oferece fluxos reprodutíveis para compilar, executar, testar, aplicar lint e migrar a aplicação.

### Scripts Principais

- `build.sh`: Invoca `cobc` com formato livre, flags de aviso e include paths para copybooks/sections.
- `run.sh`: Garante a existência dos diretórios de dados/relatórios/logs, compila quando necessário, exporta variáveis de ambiente e executa o programa.
- `reset-data.sh`: Limpa os arquivos sequenciais (`clients.dat`, `accounts.dat`, `transactions.dat`) e saídas de relatório/log, aceitando diretórios customizados.
- `lint.sh`: Executa `cobc -fsyntax-only` com avisos rigorosos para detectar problemas de sintaxe.
- `test.sh`: Compila o binário, reinicia diretórios isolados de dados, executa interações roteirizadas, valida logs/relatórios e preserva artefatos.

### Scripts de Migração

- `migrate_to_sqlite.py`: Analisa os arquivos sequenciais com layouts de comprimento fixo e popula `migrations/bankflow.sqlite`. Suporta diretórios de dados personalizados e reinicialização de esquema.
- `migrate_from_sqlite.py`: Lê o banco SQLite, valida comprimentos de registro e regenera os arquivos `.dat` no diretório escolhido (opcionalmente sobrescrevendo arquivos existentes).

### Dicas de Uso

- Defina `DATA_DIR`, `REPORT_DIR`, `LOG_DIR` ou `BANKFLOW_DATA_DIR` ao executar scripts em CI.
- Preserve artefatos gerados (`migrations/bankflow.sqlite`, logs) para depurar execuções falhas.

