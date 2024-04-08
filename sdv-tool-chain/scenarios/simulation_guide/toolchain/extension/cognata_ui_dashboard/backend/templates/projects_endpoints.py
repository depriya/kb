# Copyright (C) Microsoft Corporation
# Contains routing endpoints for projects

from cosmos_driver import CosmosDriver
from flask import Blueprint, jsonify, make_response
from flask_jwt_extended import jwt_required

projects = Blueprint("projects", __name__)


@projects.route("/getNumberOfProjects")
@jwt_required()
def getNumberOfProjects():
    driver = CosmosDriver()
    return make_response(
        jsonify({"numberOfProjects": driver.getNumberOfProjects()}), 200
    )


@projects.route("/getNumberOfSubmodels")
@jwt_required()
def getNumberOfSubmodels():
    driver = CosmosDriver()
    return make_response(
        jsonify({"numberOfSubmodels": driver.getNumberOfSubmodels()}), 200
    )
