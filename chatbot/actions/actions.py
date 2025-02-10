from __future__ import annotations

from datetime import datetime, timezone
from typing import TYPE_CHECKING, Any

from rasa_sdk import Action, Tracker
from rasa_sdk.events import SlotSet

from actions.models import parse_hours, parse_menu

if TYPE_CHECKING:
    from rasa_sdk.executor import CollectingDispatcher


class OpeningHours(Action):
    def name(self) -> str:
        return "action_opening_hours"

    def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: dict[str, Any],
    ) -> list[dict[str, Any]]:
        opening_hours = parse_hours()
        day = datetime.now(timezone.utc).strftime("%A").lower()

        msg = ""
        if day in opening_hours:
            hours = opening_hours[day]
            if hours.is_closed():
                msg = "Unfortunately, we are closed today.\n\n"
            else:
                msg = f"We are open today from {hours.open_time()} to {hours.close_time()}.\n\n"

        msg += "Our opening hours for the rest of the week are:\n"
        for day, hours in opening_hours.items():
            msg += f"* {day.capitalize()}: "
            if hours.is_closed():
                msg += "Closed\n"
            else:
                msg += f"{hours.open_time()} - {hours.close_time()}\n"

        msg += "\nNote that all times are in UTC."

        dispatcher.utter_message(text=msg)
        return []


class ListMenu(Action):
    def name(self) -> str:
        return "action_list_menu"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: dict[str, Any],
    ) -> list[dict[str, Any]]:
        menu = parse_menu()

        msg = "Our menu consists of the following items:\n"
        for item in menu:
            msg += f"* {item}\n"

        dispatcher.utter_message(text=msg)
        return []


class PlaceOrder(Action):
    def name(self) -> str:
        return "action_place_order"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: dict[str, Any],
    ) -> list[dict[str, Any]]:
        menu = parse_menu()
        order = tracker.get_slot("order")

        if order is None:
            dispatcher.utter_message(text="You have not placed an order yet.")
            return []

        if order.lower() not in menu:
            dispatcher.utter_message(text="That item is not on the menu.")
            return [SlotSet("order", None)]

        dispatcher.utter_message(text=f"Your order of {order} has been placed.")
        return [SlotSet("order", order)]


class ChoosePickup(Action):
    def name(self) -> str:
        return "action_choose_pickup"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: dict[str, Any],
    ) -> list[dict[str, Any]]:
        menu = parse_menu()
        order = tracker.get_slot("order")

        if order is None:
            dispatcher.utter_message(text="You have not placed an order yet.")
            return []

        preparation_time = int(menu[order.lower()] * 60)
        msg = f"Your order will be ready for pickup in {preparation_time} minutes."
        dispatcher.utter_message(text=msg)
        return []


class ChooseDelivery(Action):
    def name(self) -> str:
        return "action_choose_delivery"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: dict[str, Any],
    ) -> list[dict[str, Any]]:
        menu = parse_menu()
        order = tracker.get_slot("order")

        if order is None:
            dispatcher.utter_message(text="You have not placed an order yet.")
            return []

        delivery_time = int(menu[order.lower()] * 60) + 30
        msg = f"Your order will be delivered in up to {delivery_time} minutes."
        dispatcher.utter_message(text=msg)
        return []
