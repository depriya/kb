#!/bin/bash

USERNAME=$(whoami)

echo "The script is being run by: $USERNAME"

# Set your GitHub username
USERNAME="sub-AVL_DevopsPilot-id"

# Set your Personal Access Token (replace 'your_token_here' with your actual token)
TOKEN="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"

# Set your Git configuration
git config --global user.email "devi.priya@microsoft.com"
git config --global user.name "devi-priya_avl"

# Set up Git to use the Personal Access Token for authentication
git config --global credential.helper store
git config --global credential.https://github.com.username "$USERNAME"
git config --global credential.https://github.com.password "$TOKEN"

# Create and push a trigger tag
TAG_NAME="trigger-workflow-$(date +%Y%m%d%H%M%S)"  # Add a timestamp to make the tag unique
git tag -a "$TAG_NAME" -m "Trigger GitHub Actions workflow"
git push origin "$TAG_NAME"
