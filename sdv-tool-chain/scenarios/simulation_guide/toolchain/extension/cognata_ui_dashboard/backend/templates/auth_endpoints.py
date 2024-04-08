# Copyright (C) Microsoft Corporation
# Contains routing endpoints for user authentication

from flask import Blueprint, jsonify, request
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    get_jwt_identity,
    jwt_required,
)
from utilities import authenticate

authentication = Blueprint("auth", __name__)


@authentication.route("/login", methods=["POST"])
def login():
    username = request.json.get("username", None)
    password = request.json.get("password", None)
    dbUser = authenticate(username, password)
    if not dbUser:
        return jsonify({"msg": "Bad username or password"}), 401

    access_token = create_access_token(identity=username)
    return jsonify(
        access_token=access_token,
        name=dbUser["name"],
        username=username,
        refresh_token=create_refresh_token(identity=username),
    )


@authentication.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    identity = get_jwt_identity()
    access_token = create_access_token(identity=identity)
    return jsonify(access_token=access_token)


@authentication.route("/check_login")
@jwt_required()
def check_login():
    return jsonify(loggedIn=True)
