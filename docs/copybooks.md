# Copybooks – BankFlow COBOL

## Overview (English)

BankFlow COBOL centralises shared definitions in copybooks to keep divisions concise and consistent across the program.

## Visão Geral (Português)

BankFlow COBOL centraliza definições compartilhadas em copybooks para manter as divisões concisas e consistentes em todo o programa.

---

## file-control.cpy

### English
- Declares `SELECT` clauses for each sequential file with `ASSIGN TO DYNAMIC`.
- Configures organisation (`SEQUENTIAL` or `LINE SEQUENTIAL`) and status fields.
- Encapsulates descriptive comments to explain the role of each file.

### Português
- Declara as cláusulas `SELECT` de cada arquivo sequencial com `ASSIGN TO DYNAMIC`.
- Configura organização (`SEQUENTIAL` ou `LINE SEQUENTIAL`) e campos de status.
- Inclui comentários descritivos explicando o propósito de cada arquivo.

---

## file-section.cpy

### English
- Supplies FD/01 layouts for customers, accounts, transactions, reports, and logs.
- Ensures consistent record definitions between the program and auxiliary tooling.

### Português
- Fornece layouts FD/01 para clientes, contas, transações, relatórios e logs.
- Garante definições de registro consistentes entre o programa e as ferramentas auxiliares.

---

## working-storage.cpy

### English
- Holds path buffers, status codes, runtime flags, counters, and index tables.
- Defines display helpers, numeric buffers, logging fields, and timestamp storage.
- Centralises constants such as default directories, file names, and cache sizes.

### Português
- Mantém buffers de caminhos, códigos de status, flags de execução, contadores e tabelas de índice.
- Define auxiliares de exibição, buffers numéricos, campos de logging e armazenamento de timestamp.
- Centraliza constantes como diretórios padrão, nomes de arquivos e tamanhos de cache.

---

## Guidance (English)

- Add new copybooks when multiple divisions need to share definitions or constants.
- Keep record layouts in copybooks to simplify reuse in migration scripts or tests.

## Orientações (Português)

- Crie novos copybooks quando várias divisões precisarem compartilhar definições ou constantes.
- Mantenha layouts de registro em copybooks para facilitar reutilização em scripts de migração ou testes.

