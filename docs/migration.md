# Data Migration – BankFlow COBOL

## English

### Goals

- **Experiment** with SQL analytics and reporting without changing the COBOL core.
- **Prepare** a path toward indexed files or lightweight relational storage.
- **Maintain** compatibility by regenerating `clients.dat`, `accounts.dat`, and `transactions.dat` on demand.

### Script Overview

| Script | Purpose | Key Parameters | Result |
| ------ | ------- | -------------- | ------ |
| `scripts/migrate_to_sqlite.py` | Export sequential files to SQLite | `--data-dir`, `--sqlite-path`, `--reset` | Creates or refreshes `bankflow.sqlite` in `migrations/` |
| `scripts/migrate_from_sqlite.py` | Rebuild sequential files from SQLite | `--sqlite-path`, `--out-dir`, `--overwrite` | Generates `clients.dat`, `accounts.dat`, `transactions.dat` in the target dir |

Both scripts honour `BANKFLOW_DATA_DIR` unless overridden.

### Exporting to SQLite

```bash
# Create migrations/bankflow.sqlite (drops previous tables)
./scripts/migrate_to_sqlite.py --reset

# Custom data directory
./scripts/migrate_to_sqlite.py --data-dir /tmp/bankflow-data --sqlite-path /tmp/bankflow.sqlite
```

#### Schema

- `clients(id, name, cpf, address)` – CPF indexed for quick lookup.
- `accounts(number, client_id, balance_cents)` – balances stored as integer cents.
- `transactions(id, account_number, type, amount_cents, timestamp)` – preserves insertion order.
- `metadata(schema_version)` – enables future layout migrations.

Work with the resulting database using tools like `sqlite3`, DBeaver, or BI dashboards.

### Recreating Sequential Files

```bash
# Export to a temporary directory (safe default)
./scripts/migrate_from_sqlite.py

# Overwrite the data/ directory directly
./scripts/migrate_from_sqlite.py --out-dir data --overwrite
```

#### Notes

- Each record length is validated (customers: 117, accounts: 25, transactions: 44); mismatches raise explicit errors.
- `--overwrite` should be used cautiously—prefer exporting to a temporary directory first.
- Numeric values respect `PIC S9(9)V99` and are stored as integer cents; negative amounts carry a leading minus sign.

### Best Practices

- Version control scripts and documentation; generated `bankflow.sqlite` is ignored.
- Automate the export/import cycle in CI pipelines for reproducible regression tests.
- Cross-check SQLite data against sequential files (record counts, sums per customer).

### Next Steps

- Adapt the COBOL program to consume indexed files using the SQLite export as the source of truth.
- Supply diff/consistency utilities before switching from sequential to relational storage.
- Explore incremental migrations (sync only records changed since the last export).

---

## Português

### Objetivos

- **Experimentar** relatórios SQL avançados sem alterar o núcleo COBOL.
- **Preparar** a migração para arquivos indexados ou armazenamento relacional leve.
- **Manter** compatibilidade regenerando `clients.dat`, `accounts.dat` e `transactions.dat` sempre que necessário.

### Visão Geral dos Scripts

| Script | Função | Parâmetros Principais | Resultado |
| ------ | ------- | --------------------- | --------- |
| `scripts/migrate_to_sqlite.py` | Exporta arquivos sequenciais para SQLite | `--data-dir`, `--sqlite-path`, `--reset` | Cria ou atualiza `bankflow.sqlite` em `migrations/` |
| `scripts/migrate_from_sqlite.py` | Reconstrói arquivos sequenciais a partir do SQLite | `--sqlite-path`, `--out-dir`, `--overwrite` | Gera `clients.dat`, `accounts.dat`, `transactions.dat` no diretório destino |

Ambos respeitam `BANKFLOW_DATA_DIR`, salvo sobrescrita explícita.

### Exportando para SQLite

```bash
# Criar migrations/bankflow.sqlite (descarta tabelas anteriores)
./scripts/migrate_to_sqlite.py --reset

# Diretório de dados customizado
./scripts/migrate_to_sqlite.py --data-dir /tmp/bankflow-data --sqlite-path /tmp/bankflow.sqlite
```

#### Esquema

- `clients(id, name, cpf, address)` – CPF indexado para busca rápida.
- `accounts(number, client_id, balance_cents)` – saldos armazenados como centavos inteiros.
- `transactions(id, account_number, type, amount_cents, timestamp)` – mantém a ordem de inserção.
- `metadata(schema_version)` – permite futuras migrações de layout.

Utilize o banco gerado com `sqlite3`, DBeaver ou dashboards de BI.

### Recriando Arquivos Sequenciais

```bash
# Exportar para um diretório temporário (padrão seguro)
./scripts/migrate_from_sqlite.py

# Sobrescrever diretamente o diretório data/
./scripts/migrate_from_sqlite.py --out-dir data --overwrite
```

#### Observações

- O script valida o comprimento de cada registro (clientes: 117, contas: 25, transações: 44); divergências geram erros.
- `--overwrite` deve ser usado com cuidado — prefira primeiro um diretório temporário.
- Valores numéricos seguem `PIC S9(9)V99` armazenados como centavos inteiros; valores negativos recebem sinal na frente.

### Boas Práticas

- Versione scripts e documentação; o arquivo `bankflow.sqlite` permanece ignorado no Git.
- Automatize o ciclo exportar/importar em pipelines de CI para testes reproduzíveis.
- Valide dados do SQLite contra os arquivos sequenciais (contagem de registros, somatórios por cliente).

### Próximos Passos

- Adaptar o programa COBOL para consumir arquivos indexados usando o SQLite como fonte oficial.
- Disponibilizar utilitários de diff/consistência antes da troca definitiva do formato sequencial.
- Explorar migrações incrementais (sincronizar apenas registros alterados desde a última exportação).

