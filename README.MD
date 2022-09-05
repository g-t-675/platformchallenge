# Gr4vy platform challenge

### Structure 

- Each service is in it's own folder with a separate Dockerfile 
- I'm using docker-compose to build with context and prepare the setup 
- I'm using Traefik as a load balancer for path-based routing 
- I'm using a bash automation to prepare the server and install all necessary tools 
- I'm using a `.env` file for the `JWT_SECRET` which is then passed as an ENV to each container that requires it 
- One of the services was edited (it's codebase) to fix an issue

### Setup script for the challenge with Docker on Ubuntu 18.04

This is a reference setup for the platform challenge on a single Ubuntu 18.04 server, which uses Docker and Docker Compose for deployment and management. The ubuntu version is the one that I have locally. 

* I'm dockerizing each of the services using a python-slim (buster based) image, and while I'm providing a healtcheck for the auth-api and core-api services that are supposed to listen on port 5000 I'm just running them as standalones and not using any ASGI server.  PSP-connector is not listening on any port, so I'm assuming the setting of the HTTP_PORT variable in the doc of that service is a mistake, hence I'm not exposing this service 5000 port and not performing an HTTP healthcheck on it like the other 2. I've decided not to use multi-stage build as well, since there's no ASGI server and that's recommended only for prod, and not dev envs in my opinion.

* The `setup.sh` script is what runs everything: it checks if docker and docker-compose are installed, and if not it installs them both, sets up the docker permissions for the running user correctly, then proceeds on to using docker-compose to start the services. 

* I'm doing a healthcheck with `curl` for the services that are running HTTP endpoints.

* Everything related to the microservices is in the docker-compose setup: it builds each service according to the Dockerfile and tags the image with the prefix of `local/`, creates a new private docker network to forbid connections coming from the public internet and ensures safety while running all of this locally and providing internal communication between the containers. 

* The JWT token is set in the `.env` file and is read by the docker-compose, and if not set - the compose throws an error. 

* The routing is done as mentioned in the challenge description.

* I have also made a script to create a JWT token, however I would prefer not to bloat the project with unnecessary details so I'm leaving out that the .env file will contain some sample JWT secret, and the compose is smart enough to detect it and will fail if that's not the case.

## Testing and results

First, run the `setup.sh`. This will automatically set up everything and prepare everything that is needed in order for the local env to work, such as installing tools that are missing (only if they are missing), adding domains in `/etc/hosts` only if they are missing etc. Then it will run the docker-compose and start the services. 
Once they are started, make some sample requests to http://platform and check the containers logs to see if the routing is being done properly. 


```
~/gr4vy-challenge$ http -v POST http://platform/auth/token \username=alice \password=password
POST /auth/token HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 45
Content-Type: application/json
Host: platform
User-Agent: HTTPie/1.0.3

{
    "password": "password",
    "username": "alice"
}

HTTP/1.1 200 OK
Content-Length: 179
Content-Type: application/json
Date: Mon, 05 Sep 2022 18:05:01 GMT
Server: hypercorn-h11

{
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImFsaWNlIiwiZW5hYmxlZCI6dHJ1ZSwiZXhwIjoxNjYyNDAxODQ4fQ.d0cgYyO190_v5CxDtfTDLQuM9y9FvqjcsC1nSo4PMbQ"
}



~/gr4vy-challenge$ http -v POST http://platform/transaction/transaction \amount=100 \currency=USD \token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImFsaWNlIiwiZW5hYmxlZCI6dHJ1ZSwiZXhwIjoxNjYyNDAxODQ4fQ.d0cgYyO190_v5CxDtfTDLQuM9y9FvqjcsC1nSo4PMbQ
POST /transaction/transaction HTTP/1.1
Accept: application/json, */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 216
Content-Type: application/json
Host: platform
User-Agent: HTTPie/1.0.3

{
    "amount": "100",
    "currency": "USD",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImFsaWNlIiwiZW5hYmxlZCI6dHJ1ZSwiZXhwIjoxNjYyNDAxODQ4fQ.d0cgYyO190_v5CxDtfTDLQuM9y9FvqjcsC1nSo4PMbQ"
}

HTTP/1.1 200 OK
Content-Length: 44
Content-Type: application/json
Date: Mon, 05 Sep 2022 18:17:06 GMT
Server: Werkzeug/2.0.2 Python/3.9.13

{
    "amount": 100,
    "currency": "USD",
    "user_id": 1
}

~/gr4vy-challenge$ docker logs psp-connector
18:16:50 Worker rq:worker:6ff44461290f48478c6166b1c77bedc9: started, version 1.10.0
18:16:50 Subscribing to channel rq:pubsub:6ff44461290f48478c6166b1c77bedc9
18:16:50 *** Listening on default...
18:16:50 Cleaning registries for queue: default
18:17:06 default: __main__.make_transaction(amount=100, currency='USD', user_id=1) (325e17c9-4a31-46ed-a774-f83bf1824971)
==> Making transaction with PSP: User ID: 1, Amount: 100, Currency: USD
18:17:06 default: Job OK (325e17c9-4a31-46ed-a774-f83bf1824971)
18:17:06 Result is kept for 500 seconds
```

## Common issues

- The automation script is made for a Linux env, pure bash - it will not work on a mac. If on a Mac the docker-compose and everything would still work, but will need to be ran manually and also make sure all the other tools (such as docker/docker-compose, httpie etc.) are pre-installed and the /etc/hosts file is prepared.
- If this is ran on a AWS/GCP instance the user would need to re-login to take the effect of the `usermod` ran in order to allow it to work freely with the docker containers, else - a sudo might be required, which is specified in the automation script by default.



