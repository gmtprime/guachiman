FROM python:3.6-slim
MAINTAINER Alexander de Sousa (adesousa@gmtprime.corp)

RUN mkdir -p /opt/db
RUN echo "DB_HOST = 'postgres'" > /opt/my_db_settings.py
RUN echo "DB_USER = 'postgres'" >> /opt/my_db_settings.py
RUN echo "DB_PASS = 'postgres'" >> /opt/my_db_settings.py
RUN echo "DB_NAME = 'postgres'" >> /opt/my_db_settings.py
ENV BITCLOUD_DB_SETTINGS=/opt/my_db_settings.py
WORKDIR /opt/db
