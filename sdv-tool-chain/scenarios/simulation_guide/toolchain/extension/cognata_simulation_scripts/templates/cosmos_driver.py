import time

import azure.cosmos.cosmos_client as cosmos_client
from settings_factory import provideSettings


class CosmosDriver:
    def __new__(cls):
        if not hasattr(cls, "instance"):
            cls.instance = super(CosmosDriver, cls).__new__(cls)
        return cls.instance

    def __init__(self) -> None:
        self.settings = provideSettings().DATABASE
        self.client = self._createClient()

    def _createClient(self):
        return cosmos_client.CosmosClient(
            self.settings["COSMOS_URI"],
            {"masterKey": self.settings["COSMOS_PRIMARY_KEY"]},
        )

    @property
    def jobsContainerId(self):
        return self.settings["JOBS_CONTAINER"]

    @property
    def projectsContainerId(self):
        return self.settings["PROJECTS_CONTAINER"]

    @property
    def database(self):
        return self.client.create_database_if_not_exists(
            id=self.settings["DATABASE_ID"]
        )

    @property
    def jobContainer(self):
        return self.database.get_container_client(self.settings["JOBS_CONTAINER"])

    @property
    def projectContainer(self):
        return self.database.get_container_client(self.settings["PROJECTS_CONTAINER"])

    def insertJob(self, documnent):
        self.jobContainer.create_item(documnent)

    def insertProject(self, documnent):
        self.projectContainer.create_item(documnent)

    def getLatestJobsByNumber(self, numberOfJobs=25):
        dbJobs = self.jobContainer.query_items(
            "SELECT * FROM {} job ORDER BY job.lastModifiedTimestamp DESC OFFSET 0 LIMIT {}".format(
                self.jobsContainerId, numberOfJobs
            ),
            enable_cross_partition_query=True,
        )

        return list(dbJobs)

    def getLatestJobsByTimeSpan(self, timeDelta=3600):
        dbJobs = self.jobContainer.query_items(
            "SELECT * FROM {} job WHERE job.createdTimestamp > {} ".format(
                self.jobsContainerId, time.time() - timeDelta
            ),
            enable_cross_partition_query=True,
        )
        return list(dbJobs)

    def getNumberOfProjects(self):
        return list(
            self.projectContainer.query_items(
                "SELECT VALUE COUNT(id) FROM projects id",
                enable_cross_partition_query=True,
            )
        )[0]

    def getNumberOfSubmodels(self):
        queryString = "SELECT VALUE SUM(array_length(project.jobs)) FROM {} project WHERE array_length(project.jobs) > 0 ".format(
            self.settings["PROJECTS_CONTAINER"],
        )
        return list(
            self.projectContainer.query_items(
                queryString, enable_cross_partition_query=True
            )
        )[0]

    def getNumberOfRunningJobs(self):
        queryString = "SELECT VALUE SUM(job.processing) FROM {} job ".format(
            self.settings["JOBS_CONTAINER"],
        )
        return list(
            self.jobContainer.query_items(
                queryString, enable_cross_partition_query=True
            )
        )[0]
