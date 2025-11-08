#!/usr/bin/env python3
"""
Rehydrate the sequential BankFlow data files from a SQLite database produced by
`migrate_to_sqlite.py`. This allows experimentation with relational storage
without breaking compatibility with the legacy sequential layout.
"""

from __future__ import annotations

import argparse
import os
import sqlite3
from pathlib import Path
from typing import Iterable

CLIENT_RECORD_LEN = 6 + 40 + 11 + 60
ACCOUNT_RECORD_LEN = 8 + 6 + 11
TRANSACTION_RECORD_LEN = 8 + 6 + 11 + 19


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export SQLite data back to sequential .dat files.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    )
    parser.add_argument(
        "--sqlite-path",
        default=Path("migrations") / "bankflow.sqlite",
        type=Path,
        help="SQLite file used as the data source.",
    )
    parser.add_argument(
        "--out-dir",
        default=Path(os.getenv("BANKFLOW_DATA_DIR", "data-sequential-export")),
        type=Path,
        help="Destination directory for the regenerated .dat files.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite existing files in the destination directory.",
    )
    return parser.parse_args()


def format_amount_cents(value: int) -> str:
    if value < 0:
        return f"-{abs(value):010d}"
    return f"{value:011d}"


def format_clients(rows: Iterable[sqlite3.Row]) -> list[str]:
    formatted: list[str] = []
    for row in rows:
        record = (
            f"{row['id']:06d}"
            f"{row['name'][:40].ljust(40)}"
            f"{row['cpf'][:11].ljust(11)}"
            f"{row['address'][:60].ljust(60)}"
        )
        if len(record) != CLIENT_RECORD_LEN:
        raise ValueError("Client record length mismatch; please verify the data.")
        formatted.append(record)
    return formatted


def format_accounts(rows: Iterable[sqlite3.Row]) -> list[str]:
    formatted: list[str] = []
    for row in rows:
        record = (
            f"{row['number']:08d}"
            f"{row['client_id']:06d}"
            f"{format_amount_cents(int(row['balance_cents']))}"
        )
        if len(record) != ACCOUNT_RECORD_LEN:
        raise ValueError("Account record length mismatch; please verify the data.")
        formatted.append(record)
    return formatted


def format_transactions(rows: Iterable[sqlite3.Row]) -> list[str]:
    formatted: list[str] = []
    for row in rows:
        timestamp = row["timestamp"][:19].ljust(19)
        record = (
            f"{row['account_number']:08d}"
            f"{row['type'][:6].ljust(6)}"
            f"{format_amount_cents(int(row['amount_cents']))}"
            f"{timestamp}"
        )
        if len(record) != TRANSACTION_RECORD_LEN:
            raise ValueError(
                "Transaction record length mismatch; please verify the data."
            )
        formatted.append(record)
    return formatted


def write_records(path: Path, records: Iterable[str], overwrite: bool) -> int:
    rec_list = list(records)
    if path.exists() and not overwrite:
        raise FileExistsError(
            f"File {path} already exists. Use --overwrite to replace it."
        )
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("wb") as handler:
        for record in rec_list:
            handler.write(record.encode("utf-8"))
    return len(rec_list)


def export_sqlite(sqlite_path: Path, out_dir: Path, overwrite: bool) -> tuple[int, int, int]:
    if not sqlite_path.exists():
        raise FileNotFoundError(f"SQLite file not found: {sqlite_path}")

    with sqlite3.connect(sqlite_path) as conn:
        conn.row_factory = sqlite3.Row
        clients = conn.execute(
            "SELECT id, name, cpf, address FROM clients ORDER BY id"
        ).fetchall()
        accounts = conn.execute(
            "SELECT number, client_id, balance_cents FROM accounts ORDER BY number"
        ).fetchall()
        transactions = conn.execute(
            "SELECT account_number, type, amount_cents, timestamp "
            "FROM transactions ORDER BY id"
        ).fetchall()

    client_records = format_clients(clients)
    account_records = format_accounts(accounts)
    transaction_records = format_transactions(transactions)

    write_records(out_dir / "clients.dat", client_records, overwrite)
    write_records(out_dir / "accounts.dat", account_records, overwrite)
    write_records(out_dir / "transactions.dat", transaction_records, overwrite)

    return len(client_records), len(account_records), len(transaction_records)


def main() -> None:
    args = parse_args()
    counts = export_sqlite(args.sqlite_path, args.out_dir, args.overwrite)
    print(
        f"Sequential export completed at {args.out_dir} "
        f"(customers={counts[0]}, accounts={counts[1]}, transactions={counts[2]})"
    )


if __name__ == "__main__":
    main()

