#!/bin/bash

# Replace these variables with your GitHub repository details and the event type
owner="devi-priya_avl"
repo="DevOpsPilot.SiL.Workflows"
workflow_file="devbox.yml"  # Specify the YAML file you want to trigger
event_type="trigger-terraform"

# Create a repository dispatch event using Azure CLI
az rest \
  --method post \
  --uri "https://api.github.com/repos/$owner/$repo/dispatches" \
  --header "Accept=application/vnd.github.everest-preview+json" \
  --body "{ \"event_type\": \"$event_type\", \"client_payload\": { \"workflow_file\": \"$workflow_file\" } }"
