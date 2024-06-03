# Copyright (C) Microsoft Corporation.
# Copyright (C) Cognata.

import cognata_api.web_api.cognata_api_wrapper as api
from cosmos_driver import CosmosDriver
import globals
import uuid
import sys
import random
import time

class ScenarioDetails:
    def __init__(self, name, tags = [], scenarioType = "cognataScenario", permutations = 1, sku = "", sceneName = "", sceneID = ""):
        self.name = name
        self.tags = tags
        self.scenarioType = scenarioType
        self.permutations = permutations
        self.sku = sku
        self.sceneName = sceneName
        self.sceneID = sceneID

    def print_details(self):
        print("name:"+str(self.name)+" tags:"+str(self.tags)+" scenarioType:"+str(self.scenarioType)+" permutations:"+str(self.permutations)+
            " sku:"+str(self.sku)+" sceneName:"+str(self.sceneName)+" sceneID:"+str(self.sceneID)+str("\n"))

def find_test_plans_details(client_api, test_plan_sku):
    # test_plans  = client_api.get_test_plans_list(test_plan_name)
    test_plan_details = client_api.find_test_plan(test_plan_sku)
    return test_plan_details

test_plan_sku="EURONCAP"

try:
    # Open Cosmos DB connection
    driver = CosmosDriver()

    # Connect to server
    client_api = api.CognataRequests(globals.studio_url, globals.username, globals.password)
    assert client_api.is_logged_in, "Please fill in the variables in the designated cell"

    # Fetch test plan details
    test_plans_details = find_test_plans_details(client_api, test_plan_sku=test_plan_sku)

    # Iterate over scenarios
    for scenario in test_plans_details['response']['properties']['scenarios']:
        scenarioDetails_instance = ScenarioDetails(**scenario)
        scenarioDetails_instance.print_details()

        stage = random.choice(globals.STAGES)

        job = {
            "id": str(uuid.uuid4()),
            "jobId": random.randint(5,1500),
            "description": "PR {}".format(random.randint(124,15000)),
            "projectId": int(globals.get_project_id()),
            "stage": stage,
            "testPlan": scenarioDetails_instance.name,
            "success": int(random.randint(40,120)),
            "failed": int(random.randint(5,40)),
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
