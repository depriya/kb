# Copyright (C) Microsoft Corporation
# This code creates random projects/jobs when the user executes the creation command

import random
import time
import uuid

from cosmos_driver import CosmosDriver

if __name__ == "__main__":
    driver = CosmosDriver()

    CIRCUITS = [
        "Adelaide Street Circuit",
        "Ain-Diab Circuit",
        "Aintree Motor Racing Circuit",
        "Albert Park Circuit",
        "Algarve International Circuit",
        "Autódromo do Estoril",
        "Autódromo Hermanos Rodríguez",
        "Autódromo Internacional do Rio de Janeiro",
        "Autodromo Internazionale del Mugello",
        "Autodromo Internazionale Enzo e Dino Ferrari*",
        "Autodromo José Carlos Pace",
        "Autodromo Nazionale di Monza",
        "Autódromo Oscar y Juan Gálvez",
        "AVUS",
        "Bahrain International Circuit",
        "Baku City Circuit",
        "Brands Hatch Circuit",
        "Buddh International Circuit",
        "Bugatti Au Mans",
        "Caesars Palace Grand Prix Circuit",
        "Charade Circuit",
        "Circuit Bremgarten",
        "Circuit de Barcelona-Catalunya",
        "Circuit de Monaco",
        "Circuit de Nevers Magny-Cours",
        "Circuit de Pedralbes",
        "Circuit de Reims-Gueux",
        "Circuit de Spa-Francorchamps",
        "Circuit Dijon-Prenois",
        "Circuit Gilles-Villeneuve",
        "Circuit Mont-Tremblant",
        "Circuit of the Americas",
        "Circuit Paul Ricard",
        "Circuit Zandvoort",
        "Circuit Zolder",
        "Circuito da Boavista",
        "Circuito de Monsanto",
        "Circuito Permanente de Jerez",
        "Circuito Permanente del Jarama",
        "Dallas Fair Park",
        "Detroit Street Circuit",
        "Donington Park",
        "Fuji Speedway",
        "Hockenheimring",
        "Hungaroring",
        "Indianapolis Motor Speedway",
        "Intercity Istanbul Park",
        "Jeddah Corniche Circuit",
        "Korea International Circuit",
        "Kyalami Grand Prix Circuit",
        "Las Vegas Strip Circuit",
        "Long Beach Street Circuit",
        "Lusail International Circuit",
        "Marina Bay Street Circuit",
        "Miami International Autodrome",
        "Montjuïc circuit",
        "Mosport International Raceway",
        "Nivelles-Baulers",
        "Nürburgring",
        "Pescara Circuit",
        "Phoenix Street Circuit",
        "Prince George Circuit",
        "Red Bull Ring",
        "Riverside International Raceway",
        "Rouen-Les-Essarts",
        "Scandinavian Raceway",
        "Sebring Raceway",
        "Sepang International Circuit",
        "Shanghai International Circuit",
        "Silverstone Circuit",
        "Sochi Autodrom",
        "Suzuka International Racing Course",
        "TI Circuit Aida",
        "Valencia Street Circuit",
        "Watkins Glen International",
        "Yas Marina Circuit",
        "Zeltweg Airfield",
    ]

    LOCATIONS = ["EU", "LAT", "NA", "APAC"]

    STAGES = ["Complete", "Blocked", "Processing"]

    LETTERS = [
        "A",
        "B",
        "C",
        "D",
    ]

    TESTS = [
        "Euro NCAP 3.0.2",
        "Euro NCAP LSS 2.0",
        "Euro NCAP 3.0.4",
        "Euro NCAP – Highway Assist Systems",
        "ADVL - H1: Highway basic rides",
        "ADVL - U1: Urban basic rides",
    ]

    jobIDS = list(range(125, 15000))
    projectIds = list(range(4000, 10000))

    def createRandomProjects():
        numberOfSubmodels = random.choice(list(range(1, 4)))
        projectId = random.choice(projectIds)
        projectIds.remove(projectId)
        stage = random.choice(STAGES)
        project = {
            "id": str(uuid.uuid4()),
            "projectId": projectId,
            "project": "{} ECU ADAS".format(random.choice(CIRCUITS)),
            "subModels": [
                "{}_Model_{}".format(random.choice(LOCATIONS), random.choice(LETTERS))
                for i in range(0, numberOfSubmodels)
            ],
            "createdTimestamp": time.time(),
            "lastModifiedTimestamp": time.time() + random.randint(10, 2000),
        }
        numberOfJobs = random.randint(0, 10)

        projectJobs = []
        for _ in range(0, numberOfJobs):
            job = {
                "id": str(uuid.uuid4()),
                "jobId": random.randint(5, 1500),
                "description": "PR {}".format(random.randint(124, 15000)),
                "projectId": projectId,
                "stage": stage,
                "testPlan": random.choice(TESTS),
                "success": int(random.randint(40, 120)),
                "failed": int(random.randint(5, 40)),
                "processing": 0 if stage == "Complete" else random.randint(5, 40),
                "testScore": random.random(),
                "createdTimestamp": time.time(),
                "lastModifiedTimestamp": time.time() + random.randint(10, 2000),
            }
            projectJobs.append(job)

        project.update({"jobs": [job["jobId"] for job in projectJobs]})

        return project, projectJobs

    MAX_PROJECTS_JOBS = 110
    for i in range(0, MAX_PROJECTS_JOBS):
        # Sleep between projects/job creation and insertion into the Cosmos DB driver.
        # Allocates time for inserting the jobs and projects to the Cosmos DB driver before proceeding to the next projects/jobs creation.
        time.sleep(1)
        project, jobs = createRandomProjects()

        for job in jobs:
            driver.insertJob(job)
        driver.insertProject(project)
