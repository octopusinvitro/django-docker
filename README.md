[![Python version](https://badgen.net/badge/python/3.10/yellow)](Pipfile)
[![License](https://img.shields.io/github/license/octopusinvitro/django-docker)](https://github.com/octopusinvitro/django-docker/blob/main/LICENSE.md)
[![Maintainability](https://api.codeclimate.com/v1/badges/a5d393deabf01fbd6e9d/maintainability)](https://codeclimate.com/github/octopusinvitro/django-docker/maintainability)


# README

This project uses **docker** and **docker compose** for local development. Other dependencies are:

* **django** as the web framework,
* **PostgreSQL** for storage,
* `pipenv` for dependency management,
* `unittest` as the testing framework,
* `coverage` for test coverage

The dockerfile **creates a linux user** to run all the commands because the `docker-compose` file is specifying the project directory as a bind volume so that changes made locally sync with the container and viceversa. If we don't create a user these syncs would be made as the root user.

Also instead of installing `psycopg2` for posgtgres to work, we install `psycopg2-binary`, as the former needs us to install `python3-dev` and `libpq-dev` in the container and to have a C compiler etc. However, beware that [according to the documentation](https://pypi.org/project/psycopg2-binary/):

> "the binary package is a practical choice for development and testing but in production it is advised to use the package built from sources"


## Setup

* Run the `web` and `db` services specified in the `docker-compose.yml` file:

  ```sh
  . bin/run --build
  ```

  You should see both containers running:

  ```sh
  docker ps --no-trunc
  ```

* Create the database:

  ```sh
  docker compose exec db bash
  su - postgres -c 'createdb --owner=postgres --encoding=UTF8 --locale=en_US.utf8 django_docker'
  ```

  Exit both psql and the `db` docker container.

* Run the migrations and create a superuser for the project:

  ```sh
  docker compose exec web bash
  . bin/migrate
  python3 manage.py createsuperuser
  ```

  Exit the `web` docker container and go to <http:localhost:8000>.


## Development

Jump inside the `web` container:

```sh
. bin/run
docker compose exec web bash
```

and work normally from there. The changes you do to files there should sync to your local directory and viceversa.

You can stop all containers with:

```sh
docker compose down
```

An delete these containers with:

```sh
docker stop django_docker_web django_docker_db
docker rm django_docker_web django_docker_db
```

To clear all containers in the overlay folders (usually in `/var/lib/docker/image/overlay2` and `/var/lib/docker/overlay2`):

```sh
docker system prune -a -f
```


## To test

```sh
docker compose exec web bash
. bin/test                       # all tests
. bin/test app.tests.test_file # single test
```

The tests are run with the `--keepdb` option so they run faster. This means that everytime you create and run new migrations, you have to delete the test database before running the tests, so that it picks the changes:

```sh
docker compose exec db bash
su - postgres -c 'dropdb django_docker_test'

# then:
docker compose exec web bash
. bin/test
```

Running all the tests generates an HTML coverage report from the container inside of the `htmlcov` folder. You can check the coverage report locally with:

```sh
python3 -m http.server 4567
```

And then go to <http://localhost:4567/htmlcov>


## To lint

```sh
docker compose exec web bash
. bin/lint
```


## To debug

Throw an `import ipdb; ipdb.set_trace()` in the part of the code where you want to start debugging, and run the relevant tests.


# To do

The files in `.dockerignore` are not being ignored because for local development, the `docker-compose.yml` file specifies this bind directory for the `web` service:

```yml
volumes:
  - .:/app
```

So this option would have to be removed before creating the final image for deployment, as well as the `--dev` option of `pipfile` in the `Dockerfile`.
