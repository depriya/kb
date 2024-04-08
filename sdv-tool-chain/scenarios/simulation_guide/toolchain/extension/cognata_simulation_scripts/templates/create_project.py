# Copyright (C) Microsoft Corporation.
# Copyright (C) Cognata.

import random
import sys
import time
import uuid

import globals
from cosmos_driver import CosmosDriver


def createProject():
    numberOfSubmodels = random.choice(list(range(1, 4)))
    projectId = random.choice(projectIds)
    projectIds.remove(projectId)
    project = {
        "id": str(uuid.uuid4()),
        "projectId": projectId,
        "project": "{} ECU ADAS".format(random.choice(globals.CIRCUITS)),
        "subModels": [
            "{}_Model_{}".format(
                random.choice(globals.LOCATIONS), random.choice(globals.LETTERS)
            )
            for i in range(0, numberOfSubmodels)
        ],
        "createdTimestamp": time.time(),
        "lastModifiedTimestamp": time.time() + random.randint(10, 2000),
    }
    return project, projectId


try:
    jobIDS = list(range(125, 15000))
    projectIds = list(range(4000, 10000))
    driver = CosmosDriver()
    project, projectId = createProject()

    globals.write_project_id(projectId)

    driver.insertProject(project)
    sys.exit(0)

except Exception:
    sys.exit(1)
