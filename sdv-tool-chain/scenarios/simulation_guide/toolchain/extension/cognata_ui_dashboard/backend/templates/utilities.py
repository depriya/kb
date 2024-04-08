# Copyright (C) Microsoft Corporation

import bcrypt
from cosmos_driver import CosmosDriver


def authenticate(username, password):
    driver = CosmosDriver()
    try:
        user = driver.getUser(username)
    except Exception:
        return None
    if user and bcrypt.checkpw(password.encode(), user["password"].encode()):
        return user


def identity(payload):
    driver = CosmosDriver()
    username = payload["identity"]
    user = driver.getUser(username)
    return user["id"]
