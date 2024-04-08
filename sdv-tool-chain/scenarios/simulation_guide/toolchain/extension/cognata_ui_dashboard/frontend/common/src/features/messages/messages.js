// Copyright (C) Microsoft Corporation.

import { createSlice} from '@reduxjs/toolkit'

export const messages = createSlice({
  name: 'messages',
  initialState: {
    messages: []
  },
  reducers: {
    addMessage: (state, action) => {
      if (state.messages.length > 2) {
        state.messages.shift();
      }
      state.messages.push(action.payload);
    },
    removeMessage: (state, _action) => {
      state.messages.shift();
    },
    removeOldMessages: (state, _action) => {
      state.messages = state.messages.filter( (item) => {
        if (item.time > Date.now() - 10000) {
          return true;
        }
        return false;
      });
    },
    dismissMessage: (state, action) => {
      state.messages = state.messages.filter( (item) => {
        if (item.id !== action.payload.id) {
          return true;
        }
        return false;
      });
    }
  }
})

// Action creators are generated for each case reducer function
export const { addMessage, removeMessage, dismissMessage, removeOldMessages } = messages.actions
export default messages.reducer
