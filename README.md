# This is containerized and frontend-backend-separated [RealWorld example apps](https://github.com/gothinkster/realworld) (based on [Vue.js frontend](https://github.com/gothinkster/vue-realworld-example-app) and [Django backend](https://github.com/gothinkster/django-realworld-example-app) ) #

## Architecture ##

`RealWorldAppContainer` consists of 3 parts:

* frontend: Pure vue.js web frontend. All necessary data are requested from backend through URL with `/api` prefix.

* backend: Django web backend. Consists of uwsgi+nginx server for API-access and postgresql for data-storage.

* reverse proxy: Hides frontend and backend under same domain name for access.

Relation between them is as following shows:

```
               +---+----+
               | PROXY  |
               +-+----+-+
                 |    |
                 |    |
             /   |    | /api
                 |    |
+--------+       |    |       +-------+
|FRONTEND+<------+    +------>+BACKEND|
+--------+                    +---+---+
                                  |
                                  |
                                  v
                              +---+----+
                              |DATABASE|
                              +--------+
```

## Requirement ##

* Docker(18.09.3 or up)
* Docker Compose(1.24.0 or up)

## How to deploy ##

1. Clone the repository.

    `$ git clone https://github.com/HallBlazzar/RealWorldAppContainer.git`

2. Clone [Vue.js frontend](https://github.com/gothinkster/vue-realworld-example-app) to `${path_to_project_directory}/frontend/frontend`

    `$ git clone https://github.com/gothinkster/vue-realworld-example-app.git ${path_to_project_directory}/frontend/frontend`

3. Clone [Django backend](https://github.com/gothinkster/django-realworld-example-app) to `${path_to_project_directory}/backend/backend`

    `$ git clone https://github.com/gothinkster/django-realworld-example-app.git ${path_to_project_directory}/backend/backend`

4. Configure options in `.env` file based on requirement

    | Option | Description | Default Value |
    |-|-|-|
    | DATABASE_NAME | database name for storing data for backend | demo |
    | DATABASE_USER | user name to access postgresql | demo |
    | DATABASE_HOST | database host name, only modify it if you don't want to store data in postgresql database provided by `RealWorldAppContainer` | database |
    | DATABASE_PORT | port number of database service , only modify it if you don't want to store data in postgresql database provided by `RealWorldAppContainer` | 5432 |
    | SERVICE_DOMAIN_NAME | domain name to access `RealWorldAppContainer` service | demo.com |
    | WSGI_PROCESSES | number of wsgi processes of backend, modify it for performance requirement | 10 |
    | NGINX_WORKER_PROCESS | number of nginx worker processes of backend, modify it for performance requirement | 1 |
    | NGINX_KEEP_ALIVE_TIMEOUT | connection timeout of nginx of backend, modify it for performance requirement | 65 |
    | NGINX_CLIENT_MAX_BODY_SIZE | max request body size of nginx of backend, modify it for performance requirement | 75M |

5. Build necessary docker images (frontend and backend).

    `$ cd ${path_to_project_directory}`

    `$ docker-compose build`

6. Start service.

    `$ docker-compose up`

7. Open the browser and access `http://demo.com/` (or `http://${SERVICE_DOMAIN_NAME}/` based on your configuration)

## Q&A ##

* Why do we need a reverse proxy in this setup?

    Reverse proxy can hide frontend and backend under same domain name, which allow users access the `RealWorldAppContainer` service without having to know where frontend and backend actually are, respectively. Reverse proxy also hides detail of architecture, which means even if some extra functions added and these functions are deployed to another containers or hosts, they can still be accessed from same entry-point.

    In addition, reverse-proxy used by this project is [traefik](https://traefik.io/), which also provide basic load-balancing functions such as Least-First or Round-Robin. It allows user deploy multiple replications of service but can still accessed by single domain name.

* What are "database migrations", Why are they needed?

    For Django of backend, whenever connecting to new (or 'blank') database, it need to do `database migration` to construct requested table and fields first to allow it store data latter. Many modern web frame works such as `Laravel` of `php` language also support this feature to allow users initialize database in single command, which also allow users can easily deploy and manage different version of database schema.

* What are stateless applications? Are the containers in this setup stateless? Why are stateless containers preferred for docker setups?

    Actually every applications have states and states of them are determined by input. But stateless application means state of service is not determined by persist data, such as data in database or files, but by input only. For containerized service, if service itself is stateless, it means no matter where it deployed, it will always has same initial state. It can also ensure that even multiple replications of service are deployed, their own state won't effect each other.

    So, more precisely, for `RealWorldAppContainer`, frontend and backend are stateless because they only provides static contents and CURD functions to users. However, database is not. Because if different replications are deployed, the data won't be automatically synced which will cause state of different databases are different.
