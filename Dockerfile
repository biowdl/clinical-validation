FROM python:3.8.6-slim-buster

RUN pip3 install plotly
COPY src/parse_summary.py /usr/local/sbin/parse_summary
