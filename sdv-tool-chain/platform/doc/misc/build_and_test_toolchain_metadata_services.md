_Copyright (C) Microsoft Corporation_

# Build and Test Toolchain Metadata Services

To run [./github/workflows/build_and_test_toolchain_metadata_services.yml](../../../.github/workflows/build_and_test_toolchain_metadata_services.yml) locally, that is to build a docker image for tests and run a container, use the following commands:

1. Clone the repository locally and change directory into it, for example:

```bash
$ git clone <REPO>
$ cd <REPO_FOLDER>
```

The rest of the commands should be run from the `<REPO_FOLDER>`.

1. Build the image

```bash
$ docker build -f platform/toolchain/Dockerfile --target test -t pr-workflow/toolchain-tests:latest platform/toolchain
```

2. Run a container

**Note:** the image is built with `COPY` src and test inside the image, that's ok for workflow. To test locally, there is no need to rebuild the container each time, simply map the `--volume` with the source code from host into the container.

```bash
$ docker run --user ${UID} --volume ${PWD}/platform/toolchain:/toolchain --rm pr-workflow/toolchain-tests
```

Example output:

```
============================= test session starts ==============================
platform linux -- Python 3.11.4, pytest-7.4.0, pluggy-1.2.0
rootdir: /toolchain
collected 1 item

tests/test_toolchain_cli.py .                                             [100%]

============================== 1 passed in 0.01s ===============================
```
