FROM ubuntu:latest

RUN apt-get -q update && apt-get upgrade -y

COPY . /app
WORKDIR /app

CMD ["bash", "./script.sh"]

