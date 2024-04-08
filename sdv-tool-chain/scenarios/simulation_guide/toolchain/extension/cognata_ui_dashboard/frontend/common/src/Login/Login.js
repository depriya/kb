// Copyright (C) Microsoft Corporation.

import { useEffect, useState } from "react";
import { Banner } from "../Banner/Banner";
import { makeStyles} from '@fluentui/react-components';
import { history } from "../PrivateRoute/helper";
import { DashboardCard } from "../DashBoardCard/DashBoardCard";
import { useDispatch, useSelector } from "react-redux";
import { Field, Input, Textarea, Button, Spinner, MessageBar, MessageBarBody, MessageBarTitle } from "@fluentui/react-components";
import { fetchLogin } from "../features/authentication/authentication";

const useStyles = makeStyles({
  wrapper: {
   display: "flex",
   flexDirection: "column",
   width: "100%"
  },

  field: {
    height: "40px"
  },

  banner: {
    width: "100%",
    marginTop: "20px"
  },

  loginDiv: {
    "height": "auto",
    "width": "100%",
    "marginTop": "20px",
    "display": "flex",
    "justify-content": "center"
  },

  loginCard: {
    "maxHeight": "400px",
    "maxWidth": "600px",
    "marginTop": "20px"
  },

  loginButton: {
    marginTop: "20px",
    widows: "100%",
    display: "flex",
    justifyContent: "flex-end"
  }
});

export function Login(props) {
  const classes = useStyles();
  const dispatch = useDispatch();
  const loading = useSelector((state) => state.authentication.pendingLogin)
  const isLoginFailed = useSelector((state) => state.authentication.isLoginFailed)
  const isAuthenticated = useSelector((state) => state.authentication.isAuthenticated)
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  function handleChangeUsername(event){
    setUsername(event.target.value);
  }

  function handleChangePassword(event){
    setPassword(event.target.value);
  }

  function handleClick() {
    dispatch(fetchLogin({username, password}))
  }

  useEffect(() => {
    // Redirect to home if already logged in
    if (isAuthenticated) {
      history.navigate('/');
     }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  return (
    <div className={classes.wrapper}>
      <div className={classes.banner}>
        <Banner/>
      </div>
      <div className={classes.loginDiv}>
        <DashboardCard className={classes.loginCard} image={<Spinner style={{ visibility: loading ? "visible" : "hidden" }}/>} title={"Login"} caption="" content={
            <div>
              <div>
                <Field size="medium" label="Username">
                  <Textarea onChange={handleChangeUsername} className={classes.field} {...props}/>
                </Field>
                <Field size="medium" label="Password">
                  <Input onChange={handleChangePassword} className={classes.field} type="password" {...props}/>
                </Field>
                <p></p>
                <MessageBar style={{ visibility: isLoginFailed ? "visible" : "hidden" }} intent="error">
                    <MessageBarBody>
                      <MessageBarTitle>Login Failed</MessageBarTitle>
                      Check your username/password and retry
                    </MessageBarBody>
                </MessageBar>
              </div>
              <div className={classes.loginButton} onClick={handleClick}>
                <Button appearance="primary">
                  Login
                </Button>
              </div>
            </div>
          }>
        </DashboardCard>
      </div>
    </div>
  );
}
