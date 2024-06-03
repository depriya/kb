#!/bin/bash

# Copyright (C) Microsoft Corporation.

# Pre-requisites:
# sudo apt install -y plantuml graphviz

cd $(dirname $0)/..
# This uses a slightly off-white background color because #ffffff renders as transparent for some reason
plantuml -tsvg -SbackgroundColor=fefefe -checkmetadata -v **/*.puml
