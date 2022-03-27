FROM mcr.microsoft.com/vscode/devcontainers/base:0-bullseye
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        libzip-dev lua5.1 lua5.1-dev pre-commit python3-dev
RUN wget https://luarocks.org/releases/luarocks-3.8.0.tar.gz \
    && tar zxpf luarocks-3.8.0.tar.gz \
    && cd luarocks-3.8.0 \
    && ./configure && make && sudo make install \
    && cd ../ && rm -rf luarocks-3.8.0*
RUN luarocks install busted \
    && luarocks install luacheck \
    && luarocks install --deps-only luadbd
