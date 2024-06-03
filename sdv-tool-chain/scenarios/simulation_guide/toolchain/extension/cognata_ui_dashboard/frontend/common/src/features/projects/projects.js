// Copyright (C) Microsoft Corporation.

import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { GET_NUMBER_OF_PROJECTS, GET_NUMBER_OF_SUBMODELS } from './endpoints';
import { fetchWrapper } from '../utilities/fetchWrapper';

export const projects = createSlice({
  name: 'projects',
  initialState: {
    projects: [],
    numberOfProjects: 0,
    numberOfSubmodels: 0,
    loaded: false,
    loading: true,
  },
  reducers: {
    updateProjects: (state, action) => {
      Object.keys(state).forEach(key => state[key] = action[key]);
    }
  },
  extraReducers: (builder) => {
    // Add reducers for additional action types here, and handle loading state as needed
    builder.addCase(fetchNumberOfProjects.fulfilled, (state, action) => {
      // Add user to the state array
      state.loaded = true;
      state.loading = false;
      state.numberOfProjects = action.payload.numberOfProjects
    })

    builder.addCase(fetchNumberOfProjects.pending, (state, action) => {
      // Add user to the state array
      state.loading = true;
    })

  builder.addCase(fetchNumberOfSubmodels.fulfilled, (state, action) => {
    // Add user to the state array
    state.loaded = true;
    state.loading = false;
    state.numberOfSubmodels = action.payload.numberOfSubmodels
  })

  builder.addCase(fetchNumberOfSubmodels.pending, (state, action) => {
    // Add user to the state array
    state.loading = true;
  })
},
})

export const fetchNumberOfProjects = createAsyncThunk('posts/fetchNumberOfProjects', async () => {
  return await fetchWrapper.get(GET_NUMBER_OF_PROJECTS)
});

export const fetchNumberOfSubmodels = createAsyncThunk('posts/getNubmerOfSubmodels', async () => {
  return await fetchWrapper.get(GET_NUMBER_OF_SUBMODELS)
});

// Action creators are generated for each case reducer function
export const { updateProjects } = projects.actions
export default projects.reducer
