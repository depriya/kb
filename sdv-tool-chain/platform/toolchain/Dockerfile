# Copyright (C) Microsoft Corporation.

# Set up base image for cli
FROM python:3.11 as base
WORKDIR /toolchain
COPY requirements.txt .
RUN python -m pip install --upgrade pip
RUN pip install -r requirements.txt
COPY src/ src/

# Stage for running tests, linting, and formatting
FROM base as test
COPY requirements_test.txt .
COPY ruff.toml .
COPY pytest.ini .
RUN pip install -r requirements_test.txt
COPY tests/ tests/
# There can only be one CMD instruction in a Dockerfile,
# so all checks and tests are run in same script file
COPY --chmod=555 run-checks-and-tests.sh .
CMD ./run-checks-and-tests.sh
