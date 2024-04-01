#!/bin/bash

# Set your Git configuration
git config --global user.email "devi.priya@microsoft.com"
git config --global user.name "devi-priya_avl"

# Create and push a trigger tag
git tag -a trigger-workflow -m "Trigger GitHub Actions workflow"
git push origin trigger-workflow
