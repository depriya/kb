# Copyright (C) Microsoft Corporation.
# Copyright (C) Cognata.

import cognata_api.web_api.cognata_api_wrapper as api
from cosmos_driver import CosmosDriver
import globals
import uuid
import time
import sys
import random

class TestPlanResults:
    def __init__(self, failed = 0, success = 0, warnning = 0, not_available = 0, invalid = 0, no_data = 0):
        self.failed = failed
        self.success = success
        self.warnning = warnning
        self.not_available = not_available
        self.invalid = invalid
        self.no_data = no_data

    def print_result(self):
        print("Success:"+str(self.success)+ " Failed:"+str(self.failed)+" Warnning:"+str(self.warnning)+
            " invalid:"+str(self.invalid)+" no_data:"+str(self.no_data)+" not available:"+str(self.not_available))

executed_test_plans_id = ['655ca2d0fdcc27003b010fb9','655ca2d7fdcc27003b0112ea']

try:

    # Open Cosmos DB connection
    driver = CosmosDriver()

    # Connect to server
    client_api = api.CognataRequests(globals.studio_url, globals.username, globals.password)
    assert client_api.is_logged_in, "Please fill in the variables in the designated cell"

    for test_plan_run_id in executed_test_plans_id:
        res = client_api.get_test_plan_execution_runs(test_plan_run_id)
        testPlanResults_instance = TestPlanResults(**res['resolutions'])
        testPlanResults_instance.print_result()

        stage = random.choice(globals.STAGES)

        job = {
            "id": str(uuid.uuid4()),
            "jobId": random.randint(5,1500),
            "description": "PR {}".format(random.randint(124,15000)),
            "projectId": int(globals.get_project_id()),
            "stage": stage,
            "testPlan": test_plan_run_id,
            "success": testPlanResults_instance.success,
            "failed": testPlanResults_instance.failed,
            "processing": 0 if stage=="Complete" else random.randint(5,40),
            "testScore": random.random(),
            "createdTimestamp": time.time(),
            "lastModifiedTimestamp": time.time() + random.randint(10,2000)
        }
        # upload job to Cosmos DB
        driver.insertJob(job)

    sys.exit(0)

except Exception as ex:
    sys.exit(1)
