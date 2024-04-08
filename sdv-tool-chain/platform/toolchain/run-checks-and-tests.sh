#!/bin/sh
exit_status=0

ruff check .
if [ $? -ne 0 ]; then
    exit_status=1
fi

ruff format --check --diff
if [ $? -ne 0 ]; then
    exit_status=1
fi

pytest -nauto ./tests
if [ $? -ne 0 ]; then
    exit_status=1
fi

# Ensures that all checks are run before exiting, but that script fails if any check fails
exit $exit_status
