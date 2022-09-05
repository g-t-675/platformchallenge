FROM python:3.9-slim-buster


RUN apt-get update -y && apt install build-essential -y --no-install-recommends && \
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

CMD ["python3.9", "main.py"]