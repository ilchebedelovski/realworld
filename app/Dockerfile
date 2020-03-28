FROM python:3.6.8-alpine
MAINTAINER Ilche Bedelovski <ilche.bedelovski@gmail.com>

RUN apk add --no-cache python-dev && \
    apk add --no-cache g++ && \
    apk add --no-cache libffi-dev && \
    apk add --no-cache git libxml2-dev libxslt-dev libgcc openssl-dev curl jpeg-dev zlib-dev && \
    apk add --no-cache postgresql-libs && \
    apk add --no-cache --virtual .build-deps gcc musl-dev postgresql-dev

ENV CONDUIT_SECRET='something-really-secret'
ENV FLASK_APP=autoapp.py
ENV FLASK_DEBUG=1

COPY conduit /srv/app/conduit
COPY requirements /srv/app/requirements
COPY autoapp.py /srv/app
COPY tests /srv/app/tests
WORKDIR /srv/app

RUN pip install --upgrade pip && \
    pip install -r requirements/dev.txt

RUN flask db init && \
    flask db migrate && \
    flask db upgrade

EXPOSE 5000

CMD flask run --with-threads --host=0.0.0.0
