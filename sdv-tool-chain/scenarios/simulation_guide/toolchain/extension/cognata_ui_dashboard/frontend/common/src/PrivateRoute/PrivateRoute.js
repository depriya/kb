// Copyright (C) Microsoft Corporation.

// Reference: https://jasonwatmore.com/post/2022/06/15/react-18-redux-jwt-authentication-example-tutorial#private-route-jsx,
// Private routing allows rendering of React child components if the user is authenticated.
// Otherwise, the user is redirected to the login page.

import { Navigate } from 'react-router-dom';
import { useSelector } from 'react-redux';
import { history } from './helper';

export { PrivateRoute };

function PrivateRoute({ children }) {
    const isAuthenticated = useSelector((state) => state.authentication.isAuthenticated)

    if (!isAuthenticated) {
        // Not logged in. Redirect to login page with the return url
        return <Navigate to="/login" state={{from: history.location.state}}/>
    }

    // Authorized. Return child components
    return children;
}
