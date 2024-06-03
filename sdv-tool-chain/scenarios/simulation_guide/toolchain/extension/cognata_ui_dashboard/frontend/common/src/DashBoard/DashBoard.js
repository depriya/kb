// Copyright (C) Microsoft Corporation.

import * as React from "react";
import { Banner } from "../Banner/Banner";
import { makeStyles } from '@fluentui/react-components';
import { JobStatusLastHour, JobStatusLastWeek } from "../JobStatus/JobStatus";
import { Statistics } from "../Statistics/Statistics";
import { JobsTable } from "../JobsTable/JobsTable";
import CopilotLogo from "../assets/copilot.svg"
import { Messages } from "../MessageBar/MessageBar";

const useStyles = makeStyles({
  wrapper: {
    rowGap: "10px",
    columnGap: "10px",
    display: "grid",
    marginTop: "10px",
    marginLeft: "10px",
    marginRight: "10px",
    gridTemplateColumns: "30% 30% auto",
    gridTemplateRows: "auto 50% 40%",
    height: "88vh"
  },
  banner: {
    gridColumnStart: 1,
    gridColumnEnd: -1,
    marginBottom: "150px"
  },
  JobStatusLastHour: {
    gridColumnStart: 1,
    gridColumnEnd: 1,
    gridRowStart: 2,
    gridRowEnd: 2
  },
  JobStatusLastWeek: {
    gridColumnStart: 2,
    gridColumnEnd: 2,
    gridRowStart: 2,
    gridRowEnd: 2,
  },
  Statistics: {
    gridColumnStart: 3,
    gridColumnEnd: 3,
    gridRowStart: 2,
    gridRowEnd: 2,
  },
  ProjectTable: {
    gridColumnStart: 1,
    gridColumnEnd: 4,
    gridRowStart: 3,
    gridRowEnd: 3,
  },
  copilotOverlay: {
    zIndex: 40,
    position: "absolute",
    bottom: "40px",
    right: "40px"
  },
  copilotIcon: {
    '&:hover': {
        height: "60px"
    }
  }
});

export function DashBoard(props) {
  const classes = useStyles();
  return (
  <div>
    <div className={classes.wrapper}>
      <div className={classes.banner}>
        <Banner />
        <div>
          <Messages />
        </div>
      </div>
      <div className={classes.JobStatusLastHour}>
        <JobStatusLastHour />
      </div>
      <div className={classes.JobStatusLastWeek}>
        <JobStatusLastWeek/>
      </div>
      <div className={classes.Statistics}>
        <Statistics/>
      </div>
      <div className={classes.ProjectTable}>
        <JobsTable/>
      </div>
    </div>
    <div className={classes.copilotOverlay}>
      <a href="https://cescognatafinaldec20.azurewebsites.net/" target="_blank">
        <img src={CopilotLogo} className={classes.copilotIcon}></img>
      </a>
    </div>
  </div>
  );
}
