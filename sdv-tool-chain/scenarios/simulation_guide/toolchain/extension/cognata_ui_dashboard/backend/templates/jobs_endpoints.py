# Copyright (C) Microsoft Corporation
# Contains routing endpoints for jobs

from datetime import datetime, timedelta

import requests
from cosmos_driver import CosmosDriver
from flask import Blueprint, jsonify, make_response, request
from flask_jwt_extended import jwt_required
from settings_factory import provideSettings

jobs = Blueprint("jobs", __name__)


@jobs.route("/get")
@jwt_required()
def get():
    driver = CosmosDriver()
    return make_response(
        jsonify({"jobs": driver.getLatestJobsByNumbeWithProject()}), 200
    )


@jobs.route("/getRunningJobs")
@jwt_required()
def getRunningJobs():
    driver = CosmosDriver()
    return make_response(jsonify({"runningJobs": driver.getNumberOfRunningJobs()}), 200)


@jobs.route("/getJobsLastDays", methods=["POST"])
@jwt_required()
def getJobsLastDays():
    daysBehind = request.json["daysBehind"]
    driver = CosmosDriver()
    jobs = driver.getLatestJobsByTimeSpan(daysBehind * 3600 * 24)
    today = datetime.now()
    days = [today - timedelta(days=day) for day in range(0, 7)]

    jobsLastDays = {}
    for day in days:
        submittedJobs = sum(
            [
                1
                for job in jobs
                if datetime.fromtimestamp(job["createdTimestamp"]).day == day.day
            ]
        )
        completedJobs = sum(
            [
                1
                for job in jobs
                if job["stage"] == "Complete"
                and datetime.fromtimestamp(job["createdTimestamp"]).day == day.day
            ]
        )
        failedJobs = sum(
            [
                1
                for job in jobs
                if (job["stage"] == "Blocked" or job["stage"] == "Failed")
                and datetime.fromtimestamp(job["createdTimestamp"]).day == day.day
            ]
        )
        jobsLastDays["{}/{}/{}".format(day.year, day.month, day.day)] = {
            "submittedJobs": submittedJobs,
            "completedJobs": completedJobs,
            "failedJobs": failedJobs,
        }

    return make_response(jsonify({"jobs": jobsLastDays}), 200)


@jobs.route("/getJobsLastHour")
@jwt_required()
def getJobsLastHour():
    driver = CosmosDriver()
    jobs = driver.getLatestJobsByTimeSpan(3600 * 24)

    completedJobs = sum([1 for job in jobs if job["stage"] == "Complete"])
    pendingJobs = sum([1 for job in jobs if (job["stage"] == "Blocked")])
    runningJobs = sum([1 for job in jobs if (job["stage"] == "Processing")])
    failedJobs = sum([1 for job in jobs if (job["stage"] == "Failed")])

    return make_response(
        jsonify(
            {
                "jobs": {
                    "pendingJobs": pendingJobs,
                    "runningJobs": runningJobs,
                    "completedJobs": completedJobs,
                    "failedJobs": failedJobs,
                }
            }
        ),
        200,
    )


@jobs.route("/create")
@jwt_required()
def create():
    settings = provideSettings()

    try:
        json = requests.get(settings.SIMULATION_PROXY).json()
        if json["msg"] == "ok":
            return jsonify({"msg": "Success"})
        else:
            return jsonify({"msg": "Failed"})
    except Exception as error:
        return jsonify({"msg": "Failed {}".format(str(error))})
