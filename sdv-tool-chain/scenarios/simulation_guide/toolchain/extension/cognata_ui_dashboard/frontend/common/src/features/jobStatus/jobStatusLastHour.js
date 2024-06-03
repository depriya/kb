// Copyright (C) Microsoft Corporation.

import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { GET_JOBS_LAST_HOUR } from './endpoints';
import { fetchWrapper } from '../utilities/fetchWrapper';

export const jobStatusLastHour = createSlice({
  name: 'jobStatusLastHour',
  initialState: {
    lastHourLoading: false,
    lastHourLoaded: false,
    jobSummaryLastHour: {
      runningJobs: 15,
      waitingJobs: 12,
      failedJobs: 4,
      completedJobs: 34
    }
  },
  reducers: {
    updateJobStatus: (state, action) => {
      Object.keys(state).forEach(key => state[key] = action[key]);
    }
  },
  extraReducers: (builder) => {
    // Add reducers for additional action types here, and handle loading state as needed

    builder.addCase(fetchJobsLastHour.fulfilled, (state, action) => {
      // Add user to the state array
      state.lastHourLoaded = action.payload.jobs ? true : false;
      state.lastHourLoading = false;
      state.jobSummaryLastHour = action.payload.jobs ? action.payload.jobs : {}
    })

    builder.addCase(fetchJobsLastHour.pending, (state, action) => {
      // Add user to the state array
      state.lastHourLoading = true;
    })

  },
})

export const fetchJobsLastHour = createAsyncThunk('posts/fetchJobsLastHour', async () => {
  return await fetchWrapper.get(GET_JOBS_LAST_HOUR)
});

// Action creators are generated for each case reducer function
export const { updateJobStatus } = jobStatusLastHour.actions
export default jobStatusLastHour.reducer
