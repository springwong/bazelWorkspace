## Update requirements.txt

- `pip install -r requirements.txt && pip freeze > requirements_lock.txt`

## Start with docker compose

1. `docker-compose up -d db` to start postgres database
2. `docker-compose up -d` to start containers