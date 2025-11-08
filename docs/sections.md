# Procedure Sections – BankFlow COBOL

## English

### Overview

This document summarises each COBOL section included through `src/sections/main-section.cpy` and explains its responsibilities and critical paragraphs.

### Initialization Section (`initialization-section.cpy`)

- Resolves data, report, and log directories from defaults or environment variables.
- Builds dynamic file paths (`ASSIGN TO DYNAMIC`) with proper null termination.
- Ensures sequential files exist, creating them when needed.
- Opens the structured log file and records the session start.
- Triggers `INDEX-INITIALIZE` to load in-memory caches.

### Menu Section (`menu-section.cpy`)

- Displays the interactive menu, accepts user choices, and dispatches via `EVALUATE`.
- Calls domain sections (`REGISTER-CUSTOMER`, `CREATE-ACCOUNT`, `DEPOSIT-INTO-ACCOUNT`, etc.).
- Prompts for confirmation between operations and prints shutdown messaging.

### Client Section (`client-section.cpy`)

- Registers new customers with CPF sanitisation and duplicate checks.
- Provides validation paragraphs and sequential fallbacks when the index is disabled.
- Updates both the physical file and in-memory cache on success.
- Logs structured events for success, validation failures, or file errors.

### Account Section (`account-section.cpy`)

- Creates accounts linked to existing customers and assigns sequential numbers.
- Handles deposits, withdrawals, and balance inquiries with shared input helpers.
- Synchronises account balances with the index and transaction log.
- Communicates errors clearly (missing account, insufficient funds, file access).

### Report Section (`report-section.cpy`)

- Generates the activity report for a selected account.
- Streams matching transactions, writes formatted lines, and calculates the total customer balance.
- Logs outcomes (success, empty report, file issues) and reuses shared input helpers.

### Utility Section (`utility-section.cpy`)

- Formats timestamps (`BUILD-DATETIME`) and records transactions (`RECORD-TRANSACTION`).
- Centralises routines reused by multiple sections, avoiding duplication.

### Logging Section (`logging-section.cpy`)

- Writes structured log entries with timestamp, type, status, and message.
- Supports optional console echo for verbose mode.
- Handles log-file opening and disabled-log fallbacks.

### Finalize Section (`finalize-section.cpy`)

- Records the session end event and closes the structured log file.
- Resets log status flags for safe subsequent runs.

### Entry Section (`entry-section.cpy`)

- Chains initialisation, menu loop, and finalisation before returning control.
- Serves as the only paragraph invoked by `PROCEDURE DIVISION` in `BankFlow.cbl`.

---

## Português

### Visão Geral

Este documento resume cada seção COBOL incluída via `src/sections/main-section.cpy`, explicando responsabilidades e parágrafos críticos.

### Seção de Inicialização (`initialization-section.cpy`)

- Resolve diretórios de dados, relatórios e logs a partir de padrões ou variáveis de ambiente.
- Monta caminhos dinâmicos (`ASSIGN TO DYNAMIC`) com terminação nula apropriada.
- Garante a existência dos arquivos sequenciais, criando-os quando necessário.
- Abre o arquivo de log estruturado e registra o início da sessão.
- Aciona `INDEX-INITIALIZE` para carregar caches em memória.

### Seção de Menu (`menu-section.cpy`)

- Exibe o menu interativo, recebe a escolha do usuário e direciona via `EVALUATE`.
- Invoca as seções de domínio (`REGISTER-CUSTOMER`, `CREATE-ACCOUNT`, `DEPOSIT-INTO-ACCOUNT`, etc.).
- Solicita confirmação entre operações e informa o encerramento do sistema.

### Seção de Clientes (`client-section.cpy`)

- Cadastra novos clientes com higienização do CPF e verificação de duplicados.
- Oferece parágrafos de validação e fallback sequencial quando o índice está desabilitado.
- Atualiza o arquivo físico e o cache em memória em caso de sucesso.
- Registra eventos estruturados para sucessos, falhas de validação ou erros de arquivo.

### Seção de Contas (`account-section.cpy`)

- Cria contas vinculadas a clientes existentes e atribui numeração sequencial.
- Trata depósitos, saques e consultas de saldo com utilitários de entrada compartilhados.
- Sincroniza saldos das contas com o índice e registra transações.
- Comunica erros de forma clara (conta inexistente, saldo insuficiente, acesso a arquivo).

### Seção de Relatórios (`report-section.cpy`)

- Gera o relatório de movimentações para a conta selecionada.
- Processa transações correspondentes, escreve linhas formatadas e calcula o saldo total do cliente.
- Registra resultados (sucesso, relatório vazio, problemas de arquivo) e reutiliza utilitários de entrada.

### Seção de Utilidades (`utility-section.cpy`)

- Formata timestamps (`BUILD-DATETIME`) e registra transações (`RECORD-TRANSACTION`).
- Centraliza rotinas reutilizadas por várias seções, evitando duplicação.

### Seção de Logs (`logging-section.cpy`)

- Grava entradas de log estruturadas com timestamp, tipo, status e mensagem.
- Suporta eco opcional no console para modo verboso.
- Gerencia abertura do arquivo de log e fallback em caso de desativação.

### Seção de Finalização (`finalize-section.cpy`)

- Registra o encerramento da sessão e fecha o arquivo de log estruturado.
- Restaura flags de status do log para execuções futuras seguras.

### Seção de Entrada (`entry-section.cpy`)

- Encadeia inicialização, loop do menu e finalização antes de retornar o controle.
- Atua como o único parágrafo invocado pela `PROCEDURE DIVISION` em `BankFlow.cbl`.

