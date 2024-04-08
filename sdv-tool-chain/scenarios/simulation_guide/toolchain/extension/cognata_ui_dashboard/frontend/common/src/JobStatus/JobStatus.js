// Copyright (C) Microsoft Corporation.

import * as React from 'react';
import {
  VerticalStackedBarChart,
  DonutChart,
  DataVizPalette,
  getColorFromToken,
} from '@fluentui/react-charting';
import { useSelector, useDispatch } from 'react-redux'
import { DefaultPalette } from '@fluentui/react/lib/Styling';
import { makeStyles,   Spinner, Title1 } from '@fluentui/react-components';
import { DashboardCard } from '../DashBoardCard/DashBoardCard';
import { fetchLastWeekJobs } from '../features/jobStatus/jobStatusLastWeek';
import { fetchJobsLastHour } from '../features/jobStatus/jobStatusLastHour';

const useStyles = makeStyles({
  spinner: {
    height: "100%",
    flexDirection: "column",
    display: "flex",
    justifyContent: "center"
  },
  noJobText: {
    textAlign: "center"
  }
});

export function JobStatusLastHour() {
  const jobDict = useSelector((state) => state.jobStatusLastHour.jobSummaryLastHour);
  const classes = useStyles();
  const jobStautsLastHourLoading = useSelector((state) => state.jobStatusLastHour.lastHourLoading);
  const jobStatusLastHourLoaded = useSelector((state) => state.jobStatusLastHour.lastHourLoaded);
  const dispatch = useDispatch();
  let timeout = undefined;

  React.useEffect(() => {
    if (!jobStatusLastHourLoaded) {
      dispatch(fetchJobsLastHour())

      if (!timeout) {
        timeout = setInterval(
          () => { dispatch(fetchJobsLastHour()) }, 30000
        )

      }
    }
  }, [jobStatusLastHourLoaded, dispatch])

  const totalJobs = Object.keys(jobDict).reduce((partialSum, key) => partialSum + jobDict[key], 0);

  const data = {
    chartTitle: 'Running Jobs',
    chartData: [
      {
        legend: 'Running Jobs',
        data: jobDict.runningJobs,
        horizontalBarChartdata: { x: jobDict.runningJobs, y: totalJobs },
        color: getColorFromToken(DataVizPalette.info),
      },

      {
        legend: 'Pending Jobs',
        data: jobDict.waitingJobs,
        color: getColorFromToken(DataVizPalette.warning),
      },

      {
        legend: 'Failed Jobs',
        data: jobDict.failedJobs,
        color: getColorFromToken(DataVizPalette.error),
      },

      {
        legend: 'Completed Jobs',
        data: jobDict.completedJobs,
        color: getColorFromToken(DataVizPalette.color25),
      },
    ]
  };

  if (totalJobs > 0) {
    if (jobStatusLastHourLoaded) {
      return (
        <DashboardCard image={<Spinner style={{ visibility: jobStautsLastHourLoading ? "visible" : "hidden" }}/>} title="Jobs Status - Last 24 Hours" caption="Last updated - 1 min ago" content={
          <DonutChart
            data={data}
            innerRadius={100}
            legendProps={{
              allowFocusOnLegends: true,
            }}
            hideLabels={true}
            showLabelsInPercent={false}/>
        }/>
      );
    }

    else {
      return(
        <DashboardCard  image={<Spinner style={{ visibility: jobStautsLastHourLoading ? "visible" : "hidden" }}/>} title="Jobs Status - Last 24 Hours" caption="Last updated - 1 min ago" content={
          <div className={classes.spinner}>
            <Spinner></Spinner>
          </div>
        }/>
      );
    }
  }

  else {
    return(
      <DashboardCard  image={<Spinner style={{ visibility: jobStautsLastHourLoading ? "visible" : "hidden" }}/>} title="Jobs Status - Last 24 Hours" caption="Last updated - 1 min ago" content={
        <div className={classes.spinner}>
          <Title1 className={classes.noJobText}>No job in the last hour </Title1>
        </div>
      }/>
    );
  }
}

export function JobStatusLastWeek() {
    const jobDict = useSelector((state) => state.jobStatusLastWeek.jobSummaryLastWeek);
    const classes = useStyles();
    const jobStatusLastWeekLoading = useSelector((state) => state.jobStatusLastWeek.lastWeekLoading);
    const jobStatusLastWeekLoaded = useSelector((state) => state.jobStatusLastWeek.lastWeekLoaded);
    const dispatch = useDispatch();
    let timeout = undefined;

    React.useEffect(() => {
      if (!jobStatusLastWeekLoaded) {
        dispatch(fetchLastWeekJobs())

        if (!timeout) {
          timeout = setInterval(
            () => { dispatch(fetchLastWeekJobs()) }, 30000
          )
        }
      }
    }, [jobStatusLastWeekLoaded, dispatch])

    const data = Object.keys(jobDict).map( (day) => { return {
          chartData: [
              {
              legend: 'Completed Jobs',
              data: jobDict[day].completedJobs,
              color: DefaultPalette.green,
              xAxisCalloutData: day,
              yAxisCalloutData: jobDict[day].completedJobs,
            },
            {
              legend: 'Failed Jobs',
              data: jobDict[day].failedJobs,
              color: DefaultPalette.red,
              xAxisCalloutData: day,
              yAxisCalloutData: jobDict[day].failedJobs,
            },
            {
              legend: 'Submitted Jobs',
              data:jobDict[day].submittedJobs,
              color: DefaultPalette.blue,
              xAxisCalloutData: day,
              yAxisCalloutData: jobDict[day].submittedJobs,
            }],
          xAxisPoint: day
        }
    });

    if (jobStatusLastWeekLoaded) {
      return (
        <DashboardCard  image={<Spinner style={{ visibility: jobStatusLastWeekLoading ? "visible" : "hidden" }}/>} title="Jobs Status - Last Week" caption="Last updated - 5 min ago" content={
          <VerticalStackedBarChart
              chartTitle="Job Status Last Week"
              barGapMax="5"
              barWidth="30"
              data={data}
              legendProps={{
                allowFocusOnLegends: true,
              }}
              enableReflow={true}
          />}
        />
      );
    }

    else {
      return(
        <DashboardCard image={<Spinner style={{ visibility:jobStatusLastWeekLoading ? "visible" : "hidden" }} />} title="Jobs Status - Last Week" caption="Last updated - 5 min ago" content={
          <div className={classes.spinner}>
            <Spinner></Spinner>
          </div>
        }/>
      );
    }
  }
