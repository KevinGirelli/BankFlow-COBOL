# In-Memory Indexing – BankFlow COBOL

## English

### Goal

Reduce repeated linear scans over sequential files (`clients.dat`, `accounts.dat`) by caching key lookups in memory while preserving legacy compatibility.

### Structures

- `WS-CLIENT-INDEX-TABLE`
  - Up to 500 entries (`MAX-CLIENT-INDEX` configurable).
  - Stores CPF (11 digits) and customer ID.
- `WS-ACCOUNT-INDEX-TABLE`
  - Up to 500 accounts with number, customer ID, and cached balance.
- Control flags (`WS-INDEX-ENABLED`, `WS-INDEX-LOAD-FAIL`) and counters track availability and capacity.

### Lifecycle

1. **Initialise (`INDEX-INITIALIZE`)**
   - Runs after files are ensured.
   - Loads tables by scanning `clients.dat` and `accounts.dat`.
   - If any `OPEN` fails, keeps `WS-INDEX-ENABLED = "N"` and falls back to sequential reads.
2. **Online operations**
   - Customer/account creation registers new entries.
   - Deposits and withdrawals update cached balances after `REWRITE`.
   - Lookups (search, reporting, validation) use the cache when enabled, otherwise degrade gracefully to file scans.
3. **Shutdown**
   - The index lives only in memory and is rebuilt on each execution, avoiding auxiliary persistent files.

### Next Improvements

- Persist caches into dedicated files (e.g., `clients.idx`, `accounts.idx`) for instant loads.
- Record physical offsets to enable direct access when the runtime supports it.
- Provide admin commands (re-index, integrity check) and cache-hit metrics.
- Investigate dynamic limits and invalidation mechanisms for resilience.

---

## Português

### Objetivo

Reduzir buscas lineares repetidas sobre os arquivos sequenciais (`clients.dat`, `accounts.dat`) criando caches em memória, sem perder compatibilidade com o modelo legado.

### Estruturas

- `WS-CLIENT-INDEX-TABLE`
  - Até 500 entradas (`MAX-CLIENT-INDEX` configurável).
  - Armazena CPF (11 dígitos) e ID do cliente.
- `WS-ACCOUNT-INDEX-TABLE`
  - Até 500 contas com número, ID do cliente e saldo em cache.
- Flags de controle (`WS-INDEX-ENABLED`, `WS-INDEX-LOAD-FAIL`) e contadores indicam disponibilidade e capacidade.

### Ciclo de Vida

1. **Inicialização (`INDEX-INITIALIZE`)**
   - Executada após garantir a existência dos arquivos.
   - Carrega as tabelas percorrendo `clients.dat` e `accounts.dat`.
   - Se algum `OPEN` falhar, mantém `WS-INDEX-ENABLED = "N"` e utiliza a varredura sequencial.
2. **Operações online**
   - Cadastro de cliente/conta registra novas entradas.
   - Depósitos e saques atualizam o saldo em cache após o `REWRITE`.
   - Consultas, relatórios e validações usam o índice quando disponível; caso contrário, o sistema faz fallback transparente.
3. **Encerramento**
   - O índice permanece apenas em memória e é reconstruído a cada execução, evitando dependência de arquivos auxiliares.

### Próximas Evoluções

- Persistir caches em arquivos dedicados (ex.: `clients.idx`, `accounts.idx`) para carregamento imediato.
- Registrar offsets físicos para permitir acesso direto quando suportado.
- Disponibilizar comandos administrativos (reindexar, verificar integridade) e métricas de cache-hit.
- Avaliar limites dinâmicos e mecanismos de invalidação para maior resiliência.

