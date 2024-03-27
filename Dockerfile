FROM node:20-bookworm-slim

SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update && apt-get install -y curl zsh

RUN curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | zsh || true

RUN npm i -g npm@latest
RUN npm i -g bun

RUN source ~/.bashrc

RUN echo "source ~/.bashrc" >> ~/.zshrc

WORKDIR /app
