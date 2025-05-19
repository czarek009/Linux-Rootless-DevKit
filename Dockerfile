FROM ubuntu:latest

RUN apt-get -q update && apt-get upgrade -y && \
    apt-get install -y -qq curl bash ca-certificates xz-utils git make gcc fontconfig libncurses-dev

COPY . /app
WORKDIR /app

RUN chmod +x src/install_rust.sh src/uninstall_rust.sh script.sh

RUN chmod +x src/zsh/zshUninstall.sh src/zsh/zshInstall.sh

CMD ["bash", "-l", "-i", "./script.sh"]

