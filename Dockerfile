FROM oven/bun:latest

SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update && apt-get install -y curl zsh vim docker.io unzip git python3 python3-pip
RUN bun upgrade

RUN curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | zsh || true
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
RUN nvm install --lts
RUN nvm use --lts
RUN npm install -g npm@latest
RUN npm install -g zx

RUN pip3 install --upgrade pip
RUN pip3 install --upgrade awscli

RUN echo "alias python=$(which python3)" >> ~/.bashrc
RUN echo "alias pip=$(which pip3)" >> ~/.bashrc

RUN source ~/.bashrc

RUN git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
RUN sh ~/.vim_runtime/install_awesome_vimrc.sh
RUN zsh -c "cd ~/.vim_runtime && git reset --hard && git clean -d --force && git pull --rebase && python3 update_plugins.py"

RUN echo "source ~/.bashrc" >> ~/.zshrc

WORKDIR /app
