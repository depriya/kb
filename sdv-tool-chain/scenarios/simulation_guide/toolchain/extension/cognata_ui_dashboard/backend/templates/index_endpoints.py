# Copyright (C) Microsoft Corporation
# Contains a routing endpoint for the index page

import os

from flask import Blueprint, send_from_directory

index = Blueprint("index", __name__)


@index.route("/", methods=["GET"], defaults={"file": "index.html"})
@index.route("/<path:file>", methods=["GET"])
def public(file):
    return send_from_directory(
        os.path.join(os.path.dirname(__file__), "..", "..", "build"), file
    )
