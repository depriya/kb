// Copyright (C) Microsoft Corporation.

import './App.css';
import { useEffect } from 'react';
import { FluentProvider } from '@fluentui/react-components';
import { webLightTheme } from '@fluentui/react-components';
import { NavBar } from './NavBar/NavBar';
import { DashBoard } from './DashBoard/DashBoard';
import { Routes, Route, useNavigate, useLocation } from 'react-router-dom';
import { Login } from './Login/Login';
import { PrivateRoute } from './PrivateRoute/PrivateRoute';
import { history } from './PrivateRoute/helper';
import { useDispatch, useSelector } from 'react-redux';
import { checkLogin, logout } from './features/authentication/authentication';

function App() {
  history.navigate = useNavigate();
  history.location = useLocation();
  const dispatch = useDispatch();
  const isAuthenticated = useSelector((state) => state.authentication.isAuthenticated)

  useEffect(() => {
    if (isAuthenticated) {
      dispatch(checkLogin())
     } else {
      dispatch(logout())
     }
  }, []);

  return (
    <FluentProvider theme={webLightTheme}>
      <NavBar/>
      <Routes>
        <Route
          path="/"
          element={
            <PrivateRoute>
              <DashBoard/>
            </PrivateRoute>
          }
        />
        <Route
          path="/login"
          element={
            <Login/>
          }
        />
      </Routes>
    </FluentProvider>
  );
}

export default App;
