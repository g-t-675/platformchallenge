FROM python:3.9-slim-buster

EXPOSE 5000

RUN apt-get update -y && apt install build-essential curl -y --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY . /app 
WORKDIR /app 
RUN pip install --user -r requirements.txt
RUN python3.9 -m pip install --user --no-cache-dir --upgrade \
    pip \
    setuptools \
    wheel
RUN python3.9 -m pip install --user --no-cache-dir \
    -r requirements.txt

HEALTHCHECK CMD curl http://localhost:5000/health | grep -c pass || exit 1 

CMD ["python3.9", "main.py"]