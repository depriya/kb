// Copyright (C) Microsoft Corporation.

import { logout } from '../authentication/authentication'
import { useStore } from 'react-redux';
import { REFRESH_TOKEN } from '../authentication/endpoints';

export const fetchWrapper = {
    get: request('GET'),
    post: request('POST'),
    put: request('PUT'),
    delete: request('DELETE')
};

function request(method) {
    return (url, body) => {
        return fetch(
            REFRESH_TOKEN,
            {
                method: "POST",
                headers: refreshHeader()
            }
        ).then(
            (response) => {
                response.text().then(text => {
                    const data = text && JSON.parse(text);
                    localStorage.jwtToken = data.access_token
                })
                const requestOptions = {
                    method,
                    headers: authHeader()
                };
                if (body) {
                    requestOptions.headers['Content-Type'] = 'application/json';
                    requestOptions.body = JSON.stringify(body);
                }
                return fetch(url, requestOptions).then(handleResponse);
            }
        )
    }
}

function authHeader() {
    // Return auth header with jwt if user is logged in and request is to the api url
    const token = authToken();
    const isLoggedIn = !!token;
    if (isLoggedIn) {
        return { Authorization: `Bearer ${token}` };
    } else {
        return {};
    }
}

function refreshHeader(url) {
    // Return auth header with jwt if user is logged in and request is to the api url
    const token = refreshToken();
    const isLoggedIn = !!token;
    if (isLoggedIn) {
        return { Authorization: `Bearer ${token}` };
    } else {
        return {};
    }
}

function authToken() {
    return localStorage.jwtToken;
}

function refreshToken() {
    return localStorage.refreshToken;
}

function handleResponse(response) {
    return response.text().then(text => {
        const data = text && JSON.parse(text);
        if (!response.ok) {
            const unauthorized_status = 401;
            const forbidden_status = 403;
            const unprocessable_content_status = 403;
            if ([unauthorized_status, forbidden_status, unprocessable_content_status].includes(response.status) && authToken()) {
                const store = useStore();
                // Auto logout if 401 Unauthorized or 403 Forbidden response returned from api
                store.dispatch(logout());
            }

            const error = (data && data.message) || response.statusText;
            return Promise.reject(error);
        }
        return data;
    });
}
