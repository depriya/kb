// Copyright (C) Microsoft Corporation.

import * as React from 'react';
import { OpenRegular } from '@fluentui/react-icons';
import {
  createTableColumn,
  useScrollbarWidth,
  useFluent,
  Text,
  Body1Stronger,
  Spinner,
  Button
} from '@fluentui/react-components';
import {
  DataGridBody,
  DataGrid,
  DataGridRow,
  DataGridHeader,
  DataGridCell,
  DataGridHeaderCell,
} from '@fluentui-contrib/react-data-grid-react-window';

import { makeStyles } from '@fluentui/react-components';
import { DashboardCard } from '../DashBoardCard/DashBoardCard';
import { useSelector, useDispatch } from 'react-redux';
import { fetchJobs } from "../features/jobs/jobs";
import { fetchCreateJob } from '../features/jobs/jobs';

const useStyles = makeStyles({
  spinner: {
    height: "100%",
    display: "flex",
    justifyContent: "center"
  },
  buttonDiv: {
    display: "flex",
    justifyContent: "flex-end",
    width: "100%",
    marginBottom: "20px",
    marginTop: "-40px"
  }
});

const columns = [
  createTableColumn({
    columnId: "jobId",
    renderHeaderCell: () => {
      return "Job ID";
    },
    renderCell: (item) => {
      return (
        <Body1Stronger>
          {item.jobId}
        </Body1Stronger>
      );
    },
  }),

  createTableColumn({
    columnId: "description",
    renderHeaderCell: () => {
      return "Description";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.description}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "project",
    renderHeaderCell: () => {
      return "Project";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.project}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "subModels",
    renderHeaderCell: () => {
      return "Sub-Models";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.subModels}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "stage",
    renderHeaderCell: () => {
      return "Stage";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.stage}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "testPlan",
    renderHeaderCell: () => {
      return "Test Plan";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.testPlan}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "success",
    renderHeaderCell: () => {
      return "Successful";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.success}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "failed",
    renderHeaderCell: () => {
      return "Failed";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.failed}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "testScore",
    renderHeaderCell: () => {
      return "Test Score";
    },
    renderCell: (item) => {
      return (
        <Text>
          {item.testScore.toFixed(2)}
        </Text>
      );
    },
  }),

  createTableColumn({
    columnId: "singleAction",
    renderHeaderCell: () => {
      return "";
    },
    renderCell: () => {
      return <Button onClick={ () => window.open('https://44d02fb4-login.cognata-studio.com/#/')} width="100px" icon={<OpenRegular />}>Launch Test Env</Button>;
    },
  }),
];

const renderRow = ({ item, rowId }, style) => (
  <DataGridRow key={rowId} style={style}>
    {({ renderCell }) => <DataGridCell>{renderCell(item)}</DataGridCell>}
  </DataGridRow>
);

export const JobsTable = () => {
  const { targetDocument } = useFluent();
  const scrollbarWidth = useScrollbarWidth({ targetDocument });
  const classes = useStyles()
  const items = useSelector((state) => state.jobs.jobs)
  const dispatch = useDispatch()
  const projectLoaded = useSelector(state => state.jobs.loaded)
  const projectLoading = useSelector(state => state.jobs.loadingTable)
  let timeout = undefined;

  React.useEffect(() => {
    if (!projectLoaded) {
      dispatch(fetchJobs())
      if (!timeout) {
        timeout = setInterval(
          () => { dispatch(fetchJobs()) }, 30000
        )
      }
    }
  }, [projectLoaded, dispatch])

  if (projectLoaded) {
    return (
      <DashboardCard image={<Spinner style={{ visibility: projectLoading ? "visible" : "hidden" }} />} title={"All jobs"} caption="" content={
        <div className={classes.container}>
          <div className={classes.buttonDiv}>
            <Button appearance="primary" className={classes.button} onClick={() => dispatch(fetchCreateJob())}>Create Job</Button>
          </div>
          <DataGrid
            items={items}
            columns={columns}
            focusMode="cell"
            sortable
            selectionMode="multiselect">
            <DataGridHeader style={{ paddingRight: scrollbarWidth }}>
              <DataGridRow>
                {({ renderHeaderCell }) => (
                  <DataGridHeaderCell>{renderHeaderCell()}</DataGridHeaderCell>
                )}
              </DataGridRow>
            </DataGridHeader>
            <DataGridBody itemSize={50} height={250}>
              {renderRow}
            </DataGridBody>
          </DataGrid>
        </div>
      }/>
    );
  }

  else {
    return (
      <div className={classes.spinner}>
        <Spinner></Spinner>
      </div>
    );
  }
};

JobsTable.parameters = {
  docs: {
    description: {
      story: [
        'Virtualizating the DataGrid component involves recomposing components to use a virtualized container.',
        'This is already done in the extension package `@fluentui/react-data-grid-react-window` which provides',
        'extended DataGrid components that are powered',
        'by [react-window](https://react-window.vercel.app/#/examples/list/fixed-size).',
        '',
        'The example below shows how to use this extension package to virtualize the DataGrid component.',
        '',
        '> ⚠️ Make sure to memoize the row render function to avoid excessive unmouting/mounting of components.',
        'react-window will [create components based on this renderer](https://react-window.vercel.app/#/api/FixedSizeList)',
      ].join('\n'),
    },
  },
};
