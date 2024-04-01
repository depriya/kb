#!/bin/bash

# Set your Git configuration
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# Create and push a trigger tag
git tag -a trigger-workflow -m "Trigger GitHub Actions workflow"
git push origin trigger-workflow
