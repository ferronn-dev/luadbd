FROM mcr.microsoft.com/vscode/devcontainers/python:0-bullseye
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends libzip-dev lua-check pre-commit python3-dev
RUN python3 -m pip install hererocks && hererocks -l 5.1 -r 3.5.0 /usr/local
