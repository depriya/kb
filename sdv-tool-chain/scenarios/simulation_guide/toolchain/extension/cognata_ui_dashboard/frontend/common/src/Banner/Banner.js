// Copyright (C) Microsoft Corporation.

import * as React from "react";
import ContosoLogo from "../assets/contoso.png"
import {
  makeStyles,
  Text,
  shorthands,
} from "@fluentui/react-components";
import { Card } from "@fluentui/react-components";
import { tokens } from "@fluentui/react-components";

const useStyles = makeStyles({
  card: {
    ...shorthands.margin("auto"),
    width: "100%",
    maxWidth: "100%",
    height: "66px",
    backgroundColor: tokens.colorBrandBackground,
    color: tokens.colorBrandBackgroundInverted,
    display: "flex",
    flexDirection: "row",
    justifyContent: "flex-end"
  },
  logo: {
    height: "35px",
    maxWidth: "35px"
  }
});

export const Banner = () => {
  const styles = useStyles();
  return (
    <Card className={styles.card}>
      <Text as="h1" size="500" weight="bold"> Contoso Dashboard </Text>
      <img src={ContosoLogo} className={styles.logo} />
    </Card>
  );
};
