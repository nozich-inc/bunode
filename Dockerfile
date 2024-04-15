FROM node:20-bookworm-slim

SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update && apt-get install -y curl
RUN apt-get update && apt-get install -y zsh
RUN apt-get update && apt-get install -y vim
RUN apt-get update && apt-get install -y unzip
RUN apt-get update && apt-get install -y git
RUN apt-get update && apt-get install -y python3
RUN apt-get update && apt-get install -y python3-pip

COPY docker-repo.sh .
RUN chmod +x docker-repo.sh
RUN ./docker-repo.sh
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

RUN curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | zsh || true

RUN npm i -g npm@latest
RUN npm i -g zx

RUN curl -fsSL https://bun.sh/install | bash
RUN source ~/.bashrc
RUN /root/.bun/bin/bun upgrade

RUN echo "alias python=$(which python3)" >> ~/.bashrc
RUN echo "alias pip=$(which pip3)" >> ~/.bashrc
RUN source ~/.bashrc

RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
RUN sh ~/.vim_runtime/install_awesome_vimrc.sh
RUN zsh -c "cd ~/.vim_runtime && git reset --hard && git clean -d --force && git pull --rebase && python3 update_plugins.py"

RUN echo "source ~/.bashrc" >> ~/.zshrc

WORKDIR /app
