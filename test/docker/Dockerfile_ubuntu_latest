FROM ubuntu:latest

RUN apt-get -q update && apt-get upgrade -y && \
    apt-get install -y -qq curl bash ca-certificates

COPY . /app
WORKDIR /app

RUN chmod +x src/install_rust.sh src/uninstall_rust.sh script.sh

CMD ["bash", "./script.sh"]

