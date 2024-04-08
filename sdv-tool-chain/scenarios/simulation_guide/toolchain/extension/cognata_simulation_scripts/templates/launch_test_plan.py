# Copyright (C) Microsoft Corporation.
# Copyright (C) Cognata.

import cognata_api.web_api.cognata_api_wrapper as api
from cosmos_driver import CosmosDriver
import globals
import uuid
import time
import sys
import random

def find_test_plans_by_name(client_api, test_plan_name):
    test_plans  = client_api.get_test_plans_list(test_plan_name)
    return test_plans

ego_car_sku='AISUV'
sensor_preset_name= 'Single_Cam'
car_physics_sku='SUVCARPHYSICS' #Good Physics
# car_physics_sku='COGNATAS' #Bad Physics
test_plans = []
running_priority = 10

try:
    # Open Cosmos DB connection
    driver = CosmosDriver()

    # Connect to server
    client_api = api.CognataRequests(globals.studio_url, globals.username, globals.password)
    assert client_api.is_logged_in, "Please fill in the variables in the designated cell"

    # Extract sensors preset
    sensor_presets = {x['name']: x['sku'] for x in client_api.get_ego_cars_list()}

    # Get relevant test plans
    test_plan_name = "EuroNCAP Ashdod Test Track - CBNA"
    test_plans_list_NCAP_Ashdod = find_test_plans_by_name(client_api, test_plan_name=test_plan_name)

    for test_plan in test_plans_list_NCAP_Ashdod:
        if test_plan['name'] == test_plan_name:
            test_plan_sku = test_plan['sku']
            test_plan_obj=client_api.execute_test_plan(test_plan_sku=test_plan_sku, ego_car_sku=ego_car_sku, sensors_preset_sku=sensor_presets[sensor_preset_name],
                                                    car_physics_sku=car_physics_sku, tight_bb=True, running_priority=running_priority)
            test_plan_id = test_plan_obj['response']['testPlanExecutionID']

            stage = random.choice(globals.STAGES)

            job = {
                "id": str(uuid.uuid4()),
                "jobId": random.randint(5,1500),
                "description": "PR {}".format(random.randint(124,15000)),
                "projectId": int(globals.get_project_id()),
                "stage": stage,
                "testPlan": random.choice(globals.TESTS),
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
