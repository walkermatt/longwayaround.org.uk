Moving gridref to fly.io
########################
:date: 2023-03-27 11:20
:category: notes
:tags: command-line, geo, clojure, notes

A few years ago I made an effort to learn `Clojure <http://clojure.org/>`_, during which time I built a small Clojure library and command-line app `GridRef <https://github.com/walkermatt/gridref>`_ to convert between an Ordnance Survey GB grid reference and British National Grid coordinates. While I was at it I built a web API `GridRef Web <https://github.com/walkermatt/gridref-web>`_ which exposes the conversion functions via a `Ring <https://github.com/ring-clojure/ring>`_ web app. For several years gridref-web was deployed via Heroku on it's free-tier, following the free-tier coming to an end it needed a new home.

I saw mention of `fly.io <https://fly.io/>`_ a little while ago and saw they had a `genorious free tier <https://fly.io/docs/about/pricing/#free-allowances>`_ including support for custom domains, https and deployment via Docker so I thought I'd give it a go.

Creating a Dockerfile
---------------------

The first step was to create a Docker container which turned out to be straight forward. This is the :code:`Dockerfile` which is based on the `official clojure Docker image <https://hub.docker.com/_/clojure/>`_:

.. code-block:: docker

    FROM clojure
    ENV PORT=8080
    ENV JVM_OPTS="-Xmx250m"
    COPY . /usr/src/app
    WORKDIR /usr/src/app
    EXPOSE ${PORT}
    CMD lein run "${PORT}"

First we define a :code:`PORT` environment variable which determines which port the embedded Jetty HTTP server will listen on. I'm defaulting to :code:`8080` which is the default http port that fly.io will forward http requests to.

The :code:`JVM_OPTS` environment variable is used to limit the amount of memory that our app can use, I've chosen :code:`250m` which is slightly lower than the memory available to a fly.io instance on the `free tier <https://fly.io/docs/about/pricing/#free-allowances>`_.

We then copy the contents of the repo to :code:`/usr/src/app`, set the current directory (:code:`WORKDIR`) to the same and :code:`EXPOSE` the :code:`PORT`.

Finally we start the app via :code:`lein run` passing the value of the :code:`PORT` environment variable which is handled by the `main method of GridRef Web <https://github.com/walkermatt/gridref-web/blob/master/src/gridref_web/web.clj#L95>`_.

Build and run locally
---------------------

The :code:`Dockerfile` can be built and run locally via:

.. code-block:: sh

    docker build -t gridref-web .
    docker run -it --rm --memory-swap 250m --memory 250m --env PORT=8181 -p 8181:8181 --name gridref-web gridref-web


Specifying the same value for `--memory-swap` and `--memory` effectively limits the container to that much memory without swap which mimics the fly.io free-tier.

We're setting the :code:`PORT` environment variable used in the Dockerfile to determine which port the Jetty listens on; the :code:`-p` option exposes the container port to localhost for testing.

Visiting :code:`http://localhost:8181` should load the home page.

Deploy to fly.io
----------------

First download and install `flyctl <https://fly.io/docs/#flyctl-your-cli-command-center>`_ before running the following to authenticate (and create an account):

.. code-block:: sh

    flyctl auth login

Then change to the root of the :code:`gridref-web` repository and execute the following to configure the app for deployment via fly.io:

.. code-block:: sh

    flyctl launch

Running :code:`flyctl launch` prompts for various options (shown below) and creates a :code:`fly.toml` file which contains the apps configuration.

.. code-block:: sh

    # ? Choose an app name (leave blank to generate one): gridref-web
    # ? Choose a region for deployment: London, United Kingdom (lhr)
    # Created app 'gridref-web' in organization 'personal'
    # ? Would you like to set up a Postgresql database now? No
    # ? Would you like to set up an Upstash Redis database now? No
    # ? Create .dockerignore from 3 .gitignore files? Yes
    # ? Would you like to deploy now? No

These choices resulted in the following :code:`fly.toml`:

.. code-block:: toml

    app = "gridref-web"
    kill_signal = "SIGINT"
    kill_timeout = 5
    primary_region = "lhr"
    processes = []

    [env]

    [experimental]
      auto_rollback = true

    [[services]]
      http_checks = []
      internal_port = 8080
      processes = ["app"]
      protocol = "tcp"
      script_checks = []
      [services.concurrency]
        hard_limit = 25
        soft_limit = 20
        type = "connections"

      [[services.ports]]
        force_https = true
        handlers = ["http"]
        port = 80

      [[services.ports]]
        handlers = ["tls", "http"]
        port = 443

      [[services.tcp_checks]]
        grace_period = "1s"
        interval = "15s"
        restart_limit = 0
        timeout = "2s"

I couldn't see any obvious changes to :code:`fly.toml` so I moved onto deploying via:

.. code-block:: sh

    flyctl deploy

At this point the gridref-web application is available at `https://gridref-web.fly.dev/ <https://gridref-web.fly.dev/>`_.

The application is available by default via https on fly.io (with a redirect from http), I had to make a `small change to the code <https://github.com/walkermatt/gridref-web/commit/ff2b5b6bb62ec78f2816ae48ffda8e9b68c1efde>`_ to use the :code:`x-forwarded-proto` header to determine the client protocol to ensure the links shown on the home page use the correct protocol as fly.io makes requests to my application running in Docker via plain http.

Custom domain and certificate
-----------------------------

Setting up a custom domain and associated certificate for http traffic involved:

1. Creating a CNAME to point :code:`gridref.longwayaround.org.uk` at :code:`gridref-web.fly.dev.`
2. Once the CNAME had propagated, requesting a certificate via the `flyctl`:

.. code-block:: sh

    flyctl certs create gridref.longwayaround.org.uk

The web application is now available at `https://gridref.longwayaround.org.uk/ <https://gridref.longwayaround.org.uk/>`_ 🎉

The application has been running for a few weeks without any issues, it's now running via https and is more responsive due to the instance always being available.
