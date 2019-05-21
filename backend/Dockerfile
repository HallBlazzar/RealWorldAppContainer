FROM python:3.5.7

ENV LANGUAGE=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV LC_CTYPE=C.UTF-8
ENV LANG=C.UTF-8

RUN DEBIAN_FRONTEND=noninteractive

RUN echo deb http://nginx.org/packages/debian/ squeeze nginx >> /etc/apt/source.list && \
    echo deb-src http://nginx.org/packages/debian/ squeeze nginx >> /etc/apt/source.list && \
    apt-get update && \
    apt-get install -y nginx && \
	apt-get install -y gettext-base && \
    apt-get clean

RUN pip install uwsgi

COPY ./backend /opt/backend/

RUN pip install -r /opt/backend/requirements.txt && \
    pip install psycopg2

COPY ./template /opt/template
COPY ./default_value.sh /opt/default_value.sh
COPY ./start.sh /opt/start.sh

CMD ["/bin/bash", "/opt/start.sh"]
