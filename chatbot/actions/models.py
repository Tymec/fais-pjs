from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

MENU_FILE = Path("store/menu.json")
HOURS_FILE = Path("store/opening_hours.json")


def parse_menu() -> list[MenuItem]:
    with MENU_FILE.open() as f:
        menu = json.load(f)["items"]
    return [
        MenuItem(
            name=item["name"].lower(),
            price=item["price"],
            preparation_time=item["preparation_time"],
        )
        for item in menu
    ]


def parse_hours() -> dict[str, OpeningHours]:
    with HOURS_FILE.open() as f:
        hours = json.load(f)["items"]
    return {day.lower(): OpeningHours(**data) for day, data in hours.items()}


@dataclass
class MenuItem:
    name: str
    price: float
    preparation_time: float

    def __str__(self) -> str:
        return f"{self.name.capitalize()} (${self.price})"


@dataclass
class OpeningHours:
    open: int
    close: int

    def is_closed(self) -> bool:
        return self.open == 0 and self.close == 0

    def open_time(self) -> str:
        return f"{self.open:02}:00"

    def close_time(self) -> str:
        return f"{self.close:02}:00"
