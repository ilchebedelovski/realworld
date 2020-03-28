FROM python:3.6.8-alpine
MAINTAINER Ilche Bedelovski <ilche.bedelovski@gmail.com>

RUN apk add --no-cache git postgresql-client

WORKDIR /srv/app

RUN git clone https://github.com/s3tools/s3cmd.git
RUN pip install python-dateutil

COPY backup.sh /srv/app/backup.sh 

RUN chmod +x /srv/app/backup.sh
