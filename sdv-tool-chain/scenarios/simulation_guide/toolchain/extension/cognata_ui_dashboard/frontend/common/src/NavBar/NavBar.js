// Copyright (C) Microsoft Corporation.

import * as React from "react";
import ContosoLogo from "../assets/contoso.png"
import { Power24Regular } from "@fluentui/react-icons";
import {
  Toolbar,
  Badge,
  ToolbarDivider,
  Text,
  Avatar
} from "@fluentui/react-components";
import { tokens } from '@fluentui/react-theme';
import { makeStyles } from '@fluentui/react-components';
import { useSelector, useDispatch } from "react-redux";
import { logout } from "../features/authentication/authentication";

const useStyles = makeStyles({
  toolbar: {
    height: '40px',
    display: "flex",
    justifyContent: "space-between",
    color: tokens.colorNeutralForegroundInverted,
    backgroundColor: tokens.colorNeutralBackgroundInverted
  },
  icon: { height: '30px' },
  badge: { marginLeft: '20px' },
  button: {
    marginLeft: '20px',
    color: tokens.colorNeutralForegroundInverted
  },
});

export function NavBar(props) {
  const classes = useStyles();
  const isAuthenticated = useSelector((state) => state.authentication.isAuthenticated)
  const name = useSelector((state) => state.authentication.name)
  const dispatch = useDispatch();
  const initials = name ?  name[0].toUpperCase() + name.split(" ")[1][0].toUpperCase() : ""

  return (
    <Toolbar className={classes.toolbar} {...props}>
      <Toolbar className={classes.toolbar} {...props}>
        <img className={classes.icon} src={ContosoLogo} />
        <ToolbarDivider/>
        <Text>Contoso Car Dashboard</Text>
        <Badge className={classes.badge} shape="square" appearance="filled" color="warning"> Preview </Badge>
      </Toolbar>

      <Toolbar style={{visibility: isAuthenticated ? "visible" : "hidden"}} className={classes.toolbar} {...props}>
        <Power24Regular onClick={() => dispatch(logout())} className={classes.button} />
        <Avatar className={classes.button} color="brand" initials={initials} name="brand color avatar" />
      </Toolbar>
    </Toolbar>
  );
}
