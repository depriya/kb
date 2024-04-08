// Copyright (C) Microsoft Corporation.

import { createSlice, createAsyncThunk } from '@reduxjs/toolkit'
import { CHECK_LOGIN, LOGIN } from './endpoints';
import { history } from '../../PrivateRoute/helper';
import { fetchWrapper } from '../utilities/fetchWrapper';

export const authentication = createSlice({
  name: 'authentication',
  initialState: {
    isAuthenticated: localStorage.jwtToken ? true : false,
    isLoginFailed: false,
    name: "",
    username: "",
    pendingLogin: false
  },
  reducers: {
    logout: (state, action) => {
      state.isAuthenticated = false
      state.pendingLogin = false
      state.isLoginFailed = false
      localStorage.jwtToken = ""
      localStorage.refreshToken = ""
    }
  },
  extraReducers: (builder) => {
    // Add reducers for additional action types here, and handle loading state as needed
    builder.addCase(fetchLogin.fulfilled, (state, action) => {
      if (action.payload.msg) {
        state.isAuthenticated = false
        state.pendingLogin = false
        state.isLoginFailed = true
      } else {
        state.isAuthenticated = true
        state.isLoginFailed = false
        state.pendingLogin = false
        localStorage.jwtToken = action.payload.access_token
        localStorage.refreshToken = action.payload.refresh_token
        state.name = action.payload.name
        state.username = action.payload.username
        const { from } = { from: { pathname: '/' } };
        history.navigate(from);
      }

    })

    builder.addCase(fetchLogin.pending, (state, action) => {
      // Add user to the state array
      state.pendingLogin = true
    })

    builder.addCase(checkLogin.fulfilled, (state, action) => {
      // Add user to the state array
      state.isAuthenticated = action.payload.loggedIn ? true : false
    })

    builder.addCase(checkLogin.rejected, (state, action) => {
      // Add user to the state array
      state.isAuthenticated = false
    })
  },
})

export const fetchLogin = createAsyncThunk('posts/fetchLogin', async ({username, password}) => {
  const response = await fetch(LOGIN, {
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin':'*'
    },
    method: "POST",
    body: JSON.stringify({"username": username, "password": password})
  })
  return await response.json()
});

export const checkLogin = createAsyncThunk('posts/checkLogin', async () => {
  return await fetchWrapper.get(CHECK_LOGIN)
});

export const { logout } = authentication.actions

export default authentication.reducer
