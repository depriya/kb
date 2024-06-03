# Copyright (C) Microsoft Corporation.
#
# To build an image run
# $ cd /where/the/remarkjs.Dockerfile/is
# $ docker build -f remarkjs.Dockerfile -t local_tools/remarkjs:latest .
#
# To run a container and validate *.md links, run
# $ cd /git/project/with/*.md/files
# $ docker run -v $PWD:/home/remarkjs/mount:ro --rm local_tools/remarkjs

FROM node:21

RUN apt update && apt upgrade -y

WORKDIR /home/remarkjs

RUN useradd -d /home/remarkjs -m remarkjs && chown -R remarkjs:remarkjs /home/remarkjs
USER remarkjs

RUN git config --global --add safe.directory /home/remarkjs/mount
RUN npm install remark-cli remark-validate-links --save-dev

# Per https://github.com/remarkjs/remark/tree/main/packages/remark-cli#readme
# --frail - exit with 1 on warnings
# Need this to fail the pipeline if there are broken links
CMD cd ./mount && .././node_modules/.bin/remark --frail --use remark-validate-links .
