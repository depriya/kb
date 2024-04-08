// Copyright (C) Microsoft Corporation.

import { configureStore } from '@reduxjs/toolkit'
import jobStatusLastHour from '../features/jobStatus/jobStatusLastHour'
import jobStatusLastWeek from '../features/jobStatus/jobStatusLastWeek'
import jobs from '../features/jobs/jobs'
import projects from '../features/projects/projects'
import authentication from '../features/authentication/authentication'
import messages from '../features/messages/messages'

export const store = configureStore({
  reducer: {
    jobStatusLastHour: jobStatusLastHour,
    jobStatusLastWeek: jobStatusLastWeek,
    jobs: jobs,
    projects: projects,
    authentication: authentication,
    messages: messages
  }
})
