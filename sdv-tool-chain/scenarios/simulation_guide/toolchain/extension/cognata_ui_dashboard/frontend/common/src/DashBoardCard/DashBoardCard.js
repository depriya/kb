// Copyright (C) Microsoft Corporation.

import * as React from "react";
import {
  makeStyles,
  Caption1,
  Body1Stronger,
  mergeClasses,
  CardHeader,
  Divider
} from "@fluentui/react-components";
import { Card } from "@fluentui/react-components";

const useStyles = makeStyles({
    card: {
      width: "100%",
      maxWidth: "100%",
      height: "100%",
    },
    cardHeader: {
      height: "auto"
    },
    divider: {
      height: "2px"
    },
    cardPreview: {
      height: "85%",
      display: "flex",
      flexDirection: "column",
      justifyContent: "center"
    }
});

export const DashboardCard = (props) => {
  const styles = useStyles();

  return (
    <Card className={mergeClasses(styles.card, props.className)}>
      <CardHeader image={props.image} header={ <Body1Stronger> {props.title} </Body1Stronger>}  description={<Caption1>{props.caption}</Caption1>} className={styles.cardHeader}>
      </CardHeader>
      <Divider className={styles.divider}/>
      <div className={styles.cardPreview}>
        {props.content}
      </div>
    </Card>
  );
};
