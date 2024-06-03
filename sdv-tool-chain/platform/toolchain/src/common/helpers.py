"""
Copyright (C) Microsoft Corporation.

The common logic for working with metamodels
"""

from typing import Any


def update_dictionary_deep(first: dict[str, Any], second: dict[str, Any], prefix: str = "") -> dict[str, Any]:
    """
    Update `first` with `second`.

    This is a recursive update that will merge dictionaries and lists.

    Note: this function will modify `first` in-place.

    Raises a `ValueError` if the update is invalid, which can happen if:
    - `second` contains a key that is not in `first`.
    - `second` contains a key that is in `first` but the type of the value is different.

    Returns `first`.
    """
    for key, value in second.items():
        if key not in first:
            raise ValueError(f"Cannot update dictionary: unknown key '{prefix}.{key}'")

        if value.__class__ != first[key].__class__:
            raise ValueError(f"Cannot update dictionary: type mismatch for '{prefix}.{key}'")

        if isinstance(value, dict):
            first[key] = update_dictionary_deep(first.get(key, {}), value, prefix=f"{prefix}.{key}")  # type: ignore
        elif isinstance(value, list):  # Replace the existing list with the other list, like another regular value
            first[key] = value
        else:
            first[key] = value

    return first
