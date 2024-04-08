// Copyright (C) Microsoft Corporation.

import * as React from "react";
import { DashboardCard } from "../DashBoardCard/DashBoardCard";
import {
  Caption1,
  Title1,
  makeStyles,
  Spinner
} from "@fluentui/react-components";
import { useSelector, useDispatch } from 'react-redux'
import { fetchNumberOfProjects, fetchNumberOfSubmodels } from "../features/projects/projects";
import { fetchRunningJobs } from "../features/jobs/jobs";

const useStyles = makeStyles({
  wrapperStatistics: {
    rowGap: "10px",
    columnGap: "10px",
    display: "grid",
    marginTop: "10px",
    marginLeft: "10px",
    marginRight: "10px",
    gridTemplateColumns: "auto auto",
    gridTemplateRows: "auto auto",
    height: "100%"
  },
  ProjectsStats: {
    gridColumnStart: 1,
    gridColumnEnd: 1,
    gridRowStart: 1,
    gridRowEnd: 1
  },
  SubModelsStats: {
    gridColumnStart: 2,
    gridColumnEnd: 2,
    gridRowStart: 1,
    gridRowEnd: 1,
  },
  RunningJobs: {
    gridColumnStart: 1,
    gridColumnEnd: 1,
    gridRowStart: 2,
    gridRowEnd: 2,
  },
  BlockedProcesses: {
    gridColumnStart: 2,
    gridColumnEnd: 2,
    gridRowStart: 2,
    gridRowEnd: 2,
  },
  statsContainer: {

    display: "flex",
    flexDirection: "column"

  }
});

export const Statistics = () => {
  const classes = useStyles();
  const dispatch = useDispatch();
  const jobs = useSelector((state) => state.jobs);
  const jobsObject = useSelector((state) => state.jobs.jobs);
  const blockedProjects = Object.keys(jobsObject).reduce((partialSum, key) => jobsObject[key].stage === "Blocked" ? partialSum + 1 : partialSum, 0)
  const projects = useSelector((state) => state.projects);
  const numberOfSubmodels = projects.numberOfSubmodels;
  const runningJobs = useSelector((state) => state.jobs.runningJobs);
  let timeout = undefined;

  React.useEffect(() => {
    if (!jobs.loaded || !projects.loaded) {
      dispatch(fetchNumberOfProjects())
      dispatch(fetchNumberOfSubmodels())
      dispatch(fetchRunningJobs())
      if (!timeout) {
        timeout = setInterval(
          () => { dispatch(fetchNumberOfProjects()) }, 30000
        )
        timeout = setInterval(
          () => { dispatch(fetchNumberOfSubmodels()) }, 30000
        )
        timeout = setInterval(
          () => { dispatch(fetchRunningJobs()) }, 30000
        )
      }
    }
  }, [!jobs.loaded || !projects.loaded, dispatch])

  if (jobs.loaded && projects.loaded) {
    return (
      <DashboardCard title="Toolchain Stats" image={<Spinner style={{ visibility: projects.loading ? "visible" : "hidden" }} />} dashbrea caption="Last updated - 5 min ago" content={
        <div className={classes.wrapperStatistics}>
          <div className={classes.ProjectsStats}>
            <DashboardCard title="Projects" caption="Last updated - 5 min ago" content={
                <div className={classes.statsContainer}>
                  <Caption1>All Projects</Caption1>
                  <Title1>{projects.numberOfProjects}</Title1>
                </div>
              }>
            </DashboardCard>
          </div>

          <div className={classes.SubModelsStats}>
            <DashboardCard title="Sub-Models" caption="Last updated - 5 min ago" content={
                <div className={classes.statsContainer}>
                  <Caption1>All Sub-Models</Caption1>
                  <Title1>{numberOfSubmodels}</Title1>
                </div>
              }>
            </DashboardCard>
          </div>

          <div className={classes.RunningJobs}>
            <DashboardCard title="Running jobs" caption="Last updated - 5 min ago" content={
                <div className={classes.statsContainer}>
                  <Caption1>All Running Jobs</Caption1>
                  <Title1>{runningJobs}</Title1>
                </div>
              }>
            </DashboardCard>
          </div>

          <div className={classes.BlockedProcesses}>
            <DashboardCard title="Blocked Projects" caption="Last updated - 5 min ago" content={
                <div className={classes.statsContainer}>
                  <Caption1>All Blocked Projects</Caption1>
                  <Title1>{blockedProjects}</Title1>
                </div>
              }>
            </DashboardCard>
          </div>
        </div>
      }/>
    );
  }

  else {
    return (
      <DashboardCard title="Toolchain Stats" image={<Spinner style={{ visibility: projects.loading ? "visible" : "hidden" }} />} caption="Last updated - 5 min ago" content={
        <div className={classes.spinner}>
          <Spinner></Spinner>
        </div>
      }/>
    );
  };
};
