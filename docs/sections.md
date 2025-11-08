# Procedure Sections – BankFlow COBOL

## Overview (English)

This document summarises each COBOL section included through `src/sections/main-section.cpy` and explains its responsibilities and critical paragraphs.

## Visão Geral (Português)

Este documento resume cada seção COBOL incluída via `src/sections/main-section.cpy`, explicando responsabilidades e parágrafos críticos.

---

## Initialization Section / Initialization-Section.cpy

### English
- Resolves data, report, and log directories from defaults or environment variables.
- Builds dynamic file paths (`ASSIGN TO DYNAMIC`) with proper null termination.
- Ensures sequential files exist, creating them when needed.
- Opens the structured log file and records the session start.
- Triggers `INDEX-INITIALIZE` to load in-memory caches.

### Português
- Resolve diretórios de dados, relatórios e logs a partir de padrões ou variáveis de ambiente.
- Monta caminhos dinâmicos (`ASSIGN TO DYNAMIC`) com terminação nula apropriada.
- Garante a existência dos arquivos sequenciais, criando-os quando necessário.
- Abre o arquivo de log estruturado e registra o início da sessão.
- Aciona `INDEX-INITIALIZE` para carregar caches em memória.

---

## Menu Section / Menu-Section.cpy

### English
- Displays the interactive menu, accepts user choices, and dispatches via `EVALUATE`.
- Calls domain sections (`REGISTER-CUSTOMER`, `CREATE-ACCOUNT`, `DEPOSIT-INTO-ACCOUNT`, etc.).
- Prompts for confirmation between operations and prints shutdown messaging.

### Português
- Exibe o menu interativo, recebe a escolha do usuário e direciona via `EVALUATE`.
- Invoca as seções de domínio (`REGISTER-CUSTOMER`, `CREATE-ACCOUNT`, `DEPOSIT-INTO-ACCOUNT`, etc.).
- Solicita confirmação entre operações e informa o encerramento do sistema.

---

## Client Section / Client-Section.cpy

### English
- Registers new customers with CPF sanitisation and duplicate checks.
- Provides validation paragraphs and sequential fallbacks when the index is disabled.
- Updates both the physical file and in-memory cache on success.
- Logs structured events for success, validation failures, or file errors.

### Português
- Cadastra novos clientes com higienização do CPF e verificação de duplicados.
- Oferece parágrafos de validação e fallback sequencial quando o índice está desabilitado.
- Atualiza o arquivo físico e o cache em memória em caso de sucesso.
- Registra eventos estruturados para sucessos, falhas de validação ou erros de arquivo.

---

## Account Section / Account-Section.cpy

### English
- Creates accounts linked to existing customers and assigns sequential numbers.
- Handles deposits, withdrawals, and balance inquiries with shared input helpers.
- Synchronises account balances with the index and transaction log.
- Communicates errors clearly (missing account, insufficient funds, file access).

### Português
- Cria contas vinculadas a clientes existentes e atribui numeração sequencial.
- Trata depósitos, saques e consultas de saldo com utilitários de entrada compartilhados.
- Sincroniza saldos das contas com o índice e registra transações.
- Comunica erros de forma clara (conta inexistente, saldo insuficiente, acesso a arquivo).

---

## Report Section / Report-Section.cpy

### English
- Generates the activity report for a selected account.
- Streams matching transactions, writes formatted lines, and calculates the total customer balance.
- Logs outcomes (success, empty report, file issues) and reuses shared input helpers.

### Português
- Gera o relatório de movimentações para a conta selecionada.
- Processa transações correspondentes, escreve linhas formatadas e calcula o saldo total do cliente.
- Registra resultados (sucesso, relatório vazio, problemas de arquivo) e reutiliza utilitários de entrada.

---

## Utility Section / Utility-Section.cpy

### English
- Formats timestamps (`BUILD-DATETIME`) and records transactions (`RECORD-TRANSACTION`).
- Centralises routines reused by multiple sections, avoiding duplication.

### Português
- Formata timestamps (`BUILD-DATETIME`) e registra transações (`RECORD-TRANSACTION`).
- Centraliza rotinas reutilizadas por várias seções, evitando duplicação.

---

## Logging Section / Logging-Section.cpy

### English
- Writes structured log entries with timestamp, type, status, and message.
- Supports optional console echo for verbose mode.
- Handles log-file opening and disabled-log fallbacks.

### Português
- Grava entradas de log estruturadas com timestamp, tipo, status e mensagem.
- Suporta eco opcional no console para modo verboso.
- Gerencia abertura do arquivo de log e fallback em caso de desativação.

---

## Finalize Section / Finalize-Section.cpy

### English
- Records the session end event and closes the structured log file.
- Resets log status flags for safe subsequent runs.

### Português
- Registra o encerramento da sessão e fecha o arquivo de log estruturado.
- Restaura flags de status do log para execuções futuras seguras.

---

## Entry Section / Entry-Section.cpy

### English
- Chains initialisation, menu loop, and finalisation before returning control.
- Serves as the only paragraph invoked by `PROCEDURE DIVISION` in `BankFlow.cbl`.

### Português
- Encadeia inicialização, loop do menu e finalização antes de retornar o controle.
- Atua como o único parágrafo invocado pela `PROCEDURE DIVISION` em `BankFlow.cbl`.

