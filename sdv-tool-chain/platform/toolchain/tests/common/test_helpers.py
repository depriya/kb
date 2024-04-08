"""
Copyright (C) Microsoft Corporation.

Tests for the `common.helpers` module.
"""

from typing import Any

import pytest
from common.helpers import update_dictionary_deep


def test_update_dictionary_deep_successful_update():  # noqa: D103
    first = {
        "a": 1,
        "b": 2,
        "c": {"x": 1, "y": 2},
        "d": [1, 2],
    }

    second = {
        "a": 3,
        "c": {"x": 4},
        "d": [3],
    }

    expected = {
        "a": 3,
        "b": 2,
        "c": {"x": 4, "y": 2},
        "d": [3],
    }

    assert update_dictionary_deep(first, second) == expected


@pytest.mark.parametrize(
    "first, second, exception",
    [
        ({}, {"a": 1}, ValueError("Cannot update dictionary: unknown key '.a'")),
        (
            {"a": 1},
            {"a": 1.0},
            ValueError("Cannot update dictionary: type mismatch for '.a'"),
        ),
        (
            {"a": 1},
            {"a": "1"},
            ValueError("Cannot update dictionary: type mismatch for '.a'"),
        ),
        (
            {"a": {"b": 1}},
            {"a": {"b": {}}},
            ValueError("Cannot update dictionary: type mismatch for '.a.b'"),
        ),
        (
            {"a": 1},
            {"a": [1]},
            ValueError("Cannot update dictionary: type mismatch for '.a'"),
        ),
    ],
)
def test_update_dictionary_deep_cannot_update(first: dict[str, Any], second: dict[str, Any], exception: Exception):  # noqa: D103
    with pytest.raises(type(exception), match=str(exception)):
        update_dictionary_deep(first, second)
