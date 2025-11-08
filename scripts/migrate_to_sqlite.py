#!/usr/bin/env python3
"""
Convert the sequential BankFlow data files into a SQLite database while keeping
the original files untouched. The resulting database can be used for reporting,
experimentation with indexed storage, or as a stepping stone for a relational
integration layer.

Records are parsed using the fixed-length layouts defined in the COBOL
copybooks. Amounts are stored in the database as integer cents to preserve
precision; helpers are provided to expose human-readable values.
"""

from __future__ import annotations

import argparse
import sqlite3
from dataclasses import dataclass
import os
from pathlib import Path

# Record sizes (in characters) according to src/copybooks/file-section.cpy
CLIENT_RECORD_LEN = 6 + 40 + 11 + 60  # 117
ACCOUNT_RECORD_LEN = 8 + 6 + 11       # 25
TRANSACTION_RECORD_LEN = 8 + 6 + 11 + 19  # 44


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export sequential BankFlow data files to a SQLite database.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--data-dir",
        default=Path(os.getenv("BANKFLOW_DATA_DIR", "data")),
        type=Path,
        help="Directory containing clients.dat, accounts.dat and transactions.dat.",
    )
    parser.add_argument(
        "--sqlite-path",
        default=Path("migrations") / "bankflow.sqlite",
        type=Path,
        help="Destino do arquivo SQLite a ser gerado.",
    )
    parser.add_argument(
        "--reset",
        action="store_true",
        help="Recria as tabelas descartando dados existentes.",
    )
    return parser.parse_args()


def read_fixed_records(path: Path, record_len: int) -> list[str]:
    """Return a list of raw records respecting the fixed length layout."""
    if not path.exists():
        return []

    text = path.read_text(encoding="utf-8", errors="ignore")
    if not text:
        return []

    records: list[str] = []
    cursor = 0
    size = len(text)

    while cursor + record_len <= size:
        chunk = text[cursor: cursor + record_len]
        records.append(chunk)
        cursor += record_len
        # Skip optional newline or carriage return characters between records.
        while cursor < size and text[cursor] in ("\n", "\r"):
            cursor += 1

    return records


@dataclass
class Client:
    client_id: int
    name: str
    cpf: str
    address: str


@dataclass
class Account:
    number: int
    client_id: int
    balance_cents: int


@dataclass
class Transaction:
    account_number: int
    tx_type: str
    amount_cents: int
    timestamp: str


def parse_clients(path: Path) -> list[Client]:
    clients = []
    for raw in read_fixed_records(path, CLIENT_RECORD_LEN):
        if not raw.strip():
            continue
        clients.append(
            Client(
                client_id=int(raw[0:6]),
                name=raw[6:46].rstrip(),
                cpf=raw[46:57].rstrip(),
                address=raw[57:117].rstrip(),
            )
        )
    return clients


def parse_accounts(path: Path) -> list[Account]:
    accounts = []
    for raw in read_fixed_records(path, ACCOUNT_RECORD_LEN):
        if not raw.strip():
            continue
        accounts.append(
            Account(
                number=int(raw[0:8]),
                client_id=int(raw[8:14]),
                balance_cents=int(raw[14:25]),
            )
        )
    return accounts


def parse_transactions(path: Path) -> list[Transaction]:
    transactions = []
    for raw in read_fixed_records(path, TRANSACTION_RECORD_LEN):
        if not raw.strip():
            continue
        transactions.append(
            Transaction(
                account_number=int(raw[0:8]),
                tx_type=raw[8:14].rstrip(),
                amount_cents=int(raw[14:25]),
                timestamp=raw[25:44].strip(),
            )
        )
    return transactions


SCHEMA_SQL = """
BEGIN;
CREATE TABLE IF NOT EXISTS metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS clients (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    cpf TEXT NOT NULL UNIQUE,
    address TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_clients_cpf ON clients(cpf);

CREATE TABLE IF NOT EXISTS accounts (
    number INTEGER PRIMARY KEY,
    client_id INTEGER NOT NULL,
    balance_cents INTEGER NOT NULL,
    FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_accounts_client ON accounts(client_id);

CREATE TABLE IF NOT EXISTS transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    account_number INTEGER NOT NULL,
    type TEXT NOT NULL,
    amount_cents INTEGER NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (account_number) REFERENCES accounts(number) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account_number);
COMMIT;
"""


def ensure_schema(conn: sqlite3.Connection, reset: bool) -> None:
    if reset:
        conn.executescript(
            """
            BEGIN;
            DROP TABLE IF EXISTS transactions;
            DROP TABLE IF EXISTS accounts;
            DROP TABLE IF EXISTS clients;
            DROP TABLE IF EXISTS metadata;
            COMMIT;
            """
        )
    conn.executescript(SCHEMA_SQL)
    conn.execute(
        "INSERT OR REPLACE INTO metadata(key, value) VALUES(?, ?)",
        ("schema_version", "1"),
    )


def export_to_sqlite(
    data_dir: Path, sqlite_path: Path, reset: bool
) -> tuple[int, int, int]:
    sqlite_path.parent.mkdir(parents=True, exist_ok=True)

    clients = parse_clients(data_dir / "clients.dat")
    accounts = parse_accounts(data_dir / "accounts.dat")
    transactions = parse_transactions(data_dir / "transactions.dat")

    with sqlite3.connect(sqlite_path) as conn:
        conn.execute("PRAGMA foreign_keys = ON;")
        ensure_schema(conn, reset)

        conn.execute("DELETE FROM transactions;")
        conn.execute("DELETE FROM accounts;")
        conn.execute("DELETE FROM clients;")

        if clients:
            conn.executemany(
                "INSERT INTO clients(id, name, cpf, address) VALUES (?, ?, ?, ?)",
                [(c.client_id, c.name, c.cpf, c.address) for c in clients],
            )

        if accounts:
            conn.executemany(
                "INSERT INTO accounts(number, client_id, balance_cents) VALUES (?, ?, ?)",
                [(a.number, a.client_id, a.balance_cents) for a in accounts],
            )

        if transactions:
            conn.executemany(
                "INSERT INTO transactions(account_number, type, amount_cents, timestamp)"
                " VALUES (?, ?, ?, ?)",
                [
                    (t.account_number, t.tx_type, t.amount_cents, t.timestamp)
                    for t in transactions
                ],
            )

        conn.commit()

    return len(clients), len(accounts), len(transactions)


def main() -> None:
    args = parse_args()
    counts = export_to_sqlite(args.data_dir, args.sqlite_path, args.reset)
    print(
        f"Export complete: {args.sqlite_path} "
        f"(customers={counts[0]}, accounts={counts[1]}, transactions={counts[2]})"
    )


if __name__ == "__main__":
    main()

