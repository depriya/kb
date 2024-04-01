#!/bin/bash


# Set your Git configuration
#git config --global user.email "devi.priya@microsoft.com"
#git config --global user.name "devi-priya_avl"


# Create and push a trigger tag
TAG_NAME="trigger-workflow-$(date +%Y%m%d%H%M%S)"  # Add a timestamp to make the tag unique
#TAG_NAME="trigger"  # Add a timestamp to make the tag unique
git tag -a "$TAG_NAME" -m "Trigger GitHub Actions workflow"
git push origin "$TAG_NAME"
