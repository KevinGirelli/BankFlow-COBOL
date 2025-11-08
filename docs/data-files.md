# Data Files – BankFlow COBOL

## Overview (English)

BankFlow COBOL relies on three fixed-length sequential datasets plus a generated report. This guide summarises each structure and mapping.

## Visão Geral (Português)

BankFlow COBOL utiliza três arquivos sequenciais de comprimento fixo, além do relatório gerado. Este guia resume cada estrutura e mapeamento.

---

## clients.dat

### English
- Record length: 117 characters (`CLIENT-ID` 6, `CLIENT-NAME` 40, `CLIENT-CPF` 11, `CLIENT-ADDRESS` 60).
- Fields mirror `CLIENT-RECORD` in `file-section.cpy`.
- IDs are zero-padded; CPF uses digits only; address is space-padded.

### Português
- Comprimento do registro: 117 caracteres (`CLIENT-ID` 6, `CLIENT-NAME` 40, `CLIENT-CPF` 11, `CLIENT-ADDRESS` 60).
- Campos espelham `CLIENT-RECORD` em `file-section.cpy`.
- IDs possuem zeros à esquerda; CPF contém apenas dígitos; endereço é preenchido com espaços.

---

## accounts.dat

### English
- Record length: 25 characters (`ACCOUNT-NUMBER` 8, `ACCOUNT-CLIENT-ID` 6, `ACCOUNT-BALANCE` 11).
- `ACCOUNT-BALANCE` follows `PIC S9(9)V99` (implicit two decimal places).
- Updated by deposits/withdrawals and kept in sync with the account index.

### Português
- Comprimento do registro: 25 caracteres (`ACCOUNT-NUMBER` 8, `ACCOUNT-CLIENT-ID` 6, `ACCOUNT-BALANCE` 11).
- `ACCOUNT-BALANCE` segue `PIC S9(9)V99` (duas casas decimais implícitas).
- Atualizado por depósitos/saques e sincronizado com o índice de contas.

---

## transactions.dat

### English
- Record length: 44 characters (`TRANS-ACCOUNT-NUMBER` 8, `TRANS-TYPE` 6, `TRANS-AMOUNT` 11, `TRANS-DATETIME` 19).
- `TRANS-TYPE` stores values such as `CREDIT` or `DEBIT ` (6 characters).
- Amounts use integer cents; timestamps follow `YYYY-MM-DD HH:MM:SS`.

### Português
- Comprimento do registro: 44 caracteres (`TRANS-ACCOUNT-NUMBER` 8, `TRANS-TYPE` 6, `TRANS-AMOUNT` 11, `TRANS-DATETIME` 19).
- `TRANS-TYPE` armazena valores como `CREDIT` ou `DEBIT ` (6 caracteres).
- Valores monetários usam centavos inteiros; timestamps seguem `YYYY-MM-DD HH:MM:SS`.

---

## report.txt

### English
- Generated activity report containing header, account/customer metadata, transaction lines, and total balance.
- Created/reset during initialisation (`RESET-REPORT-TEXT`) and appended by `GENERATE-REPORT`.

### Português
- Relatório de movimentações contendo cabeçalho, metadados da conta/cliente, linhas de transação e saldo total.
- Criado/reiniciado na inicialização (`RESET-REPORT-TEXT`) e preenchido por `GENERATE-REPORT`.

