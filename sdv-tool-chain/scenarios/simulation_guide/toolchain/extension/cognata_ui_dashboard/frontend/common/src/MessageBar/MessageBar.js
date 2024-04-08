// Copyright (C) Microsoft Corporation.

import * as React from 'react'
import { DismissRegular } from "@fluentui/react-icons";
import { useDispatch, useSelector } from "react-redux";
import { dismissMessage, removeOldMessages } from "../features/messages/messages";
import {
  MessageBar,
  MessageBarActions,
  MessageBarTitle,
  MessageBarBody,
  MessageBarGroup,
  Button,
  makeStyles,
  shorthands,
} from "@fluentui/react-components";

const useStyles = makeStyles({
  controlsContainer: {
    display: "flex",
    flexDirection: "row",
  },
  messageBarGroup: {
  },
  message: {
    "marginTop": "10px"
  },
  field: {
    flexGrow: 1,
    alignItems: "center",
    gridTemplateColumns: "max-content auto",
  },
  buttonGroup: {
    display: "flex",
    ...shorthands.gap("5px"),
  },
  container: {
    position: "absolute",
    marginTop: "0px",
    width: "100%",
    zIndex: "100"
  }
});

export function Messages() {
  const styles = useStyles();
  const dispatch = useDispatch();
  const messages = useSelector((state) => state.messages.messages)
  const animate = "both";
  let timeout = undefined;

  React.useEffect(() => {
      if (!timeout) {
        timeout = setInterval(
          () => { dispatch(removeOldMessages()) }, 1000
        )
      }
    }, [])

  return (
    <div className={styles.container}>
      <MessageBarGroup animate={animate} className={styles.messageBarGroup}>
        {
          messages.map(({ intent, id, title, message }) => (
            <MessageBar className={styles.message} key={id} intent={intent}>
              <MessageBarBody>
                <MessageBarTitle>{title}</MessageBarTitle>
                {message}
              </MessageBarBody>
              <MessageBarActions
                containerAction={
                  <Button
                    onClick={() => dispatch(dismissMessage({id}))}
                    aria-label="dismiss"
                    appearance="transparent"
                    icon={<DismissRegular />}
                  />
                }
              />
            </MessageBar>
          ))
        }
      </MessageBarGroup>
    </div>
  );
};
