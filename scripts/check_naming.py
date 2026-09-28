#!/usr/bin/env python3
"""Fail when a model, test, or macro file breaks the banking mesh naming rules."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

# (directory, required prefix or None, exact names or None)
PROJECTS: tuple[tuple[str, str | None, frozenset[str] | None], ...] = (
    ("", "banking_", None),
    ("insurance", "insurance_", None),
    ("wealth", "wealth_", None),
    ("financials", "customer_", None),
    (
        "customer_360",
        None,
        frozenset(
            {
                "group_customer",
                "customer_360",
                "next_best_action",
                "time_spine_daily",
                "customer_profit_month",
            }
        ),
    ),
)

SNAKE = set("abcdefghijklmnopqrstuvwxyz0123456789_")


def _snake(name: str) -> bool:
    return bool(name) and name[0].isalpha() and set(name) <= SNAKE and name == name.lower()


def check_model(project: str, name: str) -> str | None:
    prefix = None
    allowed = None
    for directory, pref, names in PROJECTS:
        if directory == project:
            prefix, allowed = pref, names
            break
    if not _snake(name):
        return f"{project or 'banking'}: {name} is not snake_case"
    if allowed is not None and name not in allowed:
        return f"{project}: {name} must be one of {', '.join(sorted(allowed))}"
    if prefix and not name.startswith(prefix):
        label = project or "banking"
        return f"{label}: {name} must start with {prefix}"
    return None


def _sql_names(folder: Path) -> list[str]:
    if not folder.is_dir():
        return []
    return sorted(path.stem for path in folder.rglob("*.sql") if "target" not in path.parts)


def violations() -> list[str]:
    found: list[str] = []
    for directory, _prefix, _allowed in PROJECTS:
        base = ROOT / directory if directory else ROOT
        project = directory
        label = directory or "banking"
        for name in _sql_names(base / "models"):
            message = check_model(project, name)
            if message:
                found.append(message)
        for name in _sql_names(base / "tests"):
            if not (name.startswith("assert_") or name.startswith("warn_")) or not _snake(name):
                found.append(f"{label}: test {name} must be assert_* or warn_* in snake_case")
        for name in _sql_names(base / "macros"):
            if not _snake(name):
                found.append(f"{label}: macro {name} must be snake_case")
    return found


def main() -> int:
    bad = violations()
    if bad:
        print("\n".join(bad))
        return 1
    print("naming ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
