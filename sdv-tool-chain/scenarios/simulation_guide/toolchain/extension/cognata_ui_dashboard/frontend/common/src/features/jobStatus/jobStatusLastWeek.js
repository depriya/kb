// Copyright (C) Microsoft Corporation.

import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { GET_JOBS_LAST_DAYS } from './endpoints';
import { fetchWrapper } from '../utilities/fetchWrapper';

export const jobStatusLastWeek = createSlice({
  name: 'jobStatusLastWeek',
  initialState: {
    jobSummaryLastWeek: {
      '1': {
        completedJobs: 1,
        failedJobs: 1,
        submittedJobs: 1
      }
    },
    lastWeekLoaded: false,
    lastWeekLoading: false
  },
  reducers: {
    updateJobStatus: (state, action) => {
      Object.keys(state).forEach(key => state[key] = action[key]);
    }
  },
  extraReducers: (builder) => {
    // Add reducers for additional action types here, and handle loading state as needed

    builder.addCase(fetchLastWeekJobs.fulfilled, (state, action) => {
      // Add user to the state array
      state.lastWeekLoaded = action.payload.jobs ? true : false;
      state.lastWeekLoading = false;
      state.jobSummaryLastWeek = action.payload.jobs ? action.payload.jobs : {}
    })

    builder.addCase(fetchLastWeekJobs.pending, (state, action) => {
      // Add user to the state array
      state.lastWeekLoading = true;
    })

  },
})

export const fetchLastWeekJobs = createAsyncThunk('posts/fetchLastWeekJobs', async () => {
  return await fetchWrapper.post(GET_JOBS_LAST_DAYS, {daysBehind: 7})
});

// Action creators are generated for each case reducer function
export const { updateJobStatus } = jobStatusLastWeek.actions
export default jobStatusLastWeek.reducer
