// Copyright (C) Microsoft Corporation.

import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { CREATE_JOB, GET_JOBS_LIST, GET_RUNNING_JOBS } from './endpoints';
import { fetchWrapper } from '../utilities/fetchWrapper';
import { addMessage } from '../messages/messages';

export const jobs = createSlice({
  name: 'jobs',
  initialState: { jobs: [],
  runningJobs: 0,
  loaded: false,
  loading: true,
  loadingTable: true
 },
  reducers: {
    updateProjects: (state, action) => {
      Object.keys(state).forEach(key => state[key] = action[key]);
    }
  },
  extraReducers: (builder) => {
    // Add reducers for additional action types here, and handle loading state as needed
    builder.addCase(fetchJobs.fulfilled, (state, action) => {
      // Add user to the state array
      state.loaded = true;
      state.loadingTable = false;
      state.jobs = action.payload.jobs
    })

    builder.addCase(fetchJobs.pending, (state, action) => {
      // Add user to the state array
      state.loadingTable = true;
    })

    builder.addCase(fetchRunningJobs.fulfilled, (state, action) => {
      // Add user to the state array
      state.loaded = true;
      state.loading = false;
      state.runningJobs = action.payload.runningJobs
    })

    builder.addCase(fetchRunningJobs.pending, (state, action) => {
      // Add user to the state array
      state.loading = true;
    })
  },
})

export const fetchJobs = createAsyncThunk('posts/fetchJobs', async () => {
    return await fetchWrapper.get(GET_JOBS_LIST)
});

export const fetchRunningJobs = createAsyncThunk('posts/fetchRunningJobs', async () => {
  return await fetchWrapper.get(GET_RUNNING_JOBS)
});

export const fetchCreateJob = createAsyncThunk('posts/fetchCreateJob', async (_, {dispatch}) => {
  dispatch(addMessage({id: window.crypto.randomUUID(), intent: "info", title: "Job creation", message: "Job creation started at " + new Date().toISOString(), time: Date.now()}))
  const response = await fetchWrapper.get(CREATE_JOB)

  if (response.msg === "Success") {
    dispatch(addMessage({id: window.crypto.randomUUID(), intent: "success", title: "Job created", message: "Job successfully created at " + new Date().toISOString() , time: Date.now()}))
  }

  else {
    dispatch(addMessage({id: window.crypto.randomUUID(), intent: "error", title: "Job creation failed", message: "Job creation failed at " + new Date().toISOString(), time: Date.now() }))
  }
  return response;
});

// Action creators are generated for each case reducer function
export const { updateProjects } = jobs.actions
export default jobs.reducer
