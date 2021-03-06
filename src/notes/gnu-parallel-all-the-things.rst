GNU Parallel all the things!
############################
:date: 2014-07-17 19:45
:category: notes
:tags: command-line, postgis, notes

I've been doing a lot of data processing recently and have been looking for a way of running bulk data loads into PostGIS in parallel to make use of all available cores. The work has mainly revolved around loading national cover of Ordnance Survey OS MasterMap and VectorMap Local for `Astun Tech's <http://astuntechnology.com/>`_ base map services using `Loader <https://github.com/AstunTechnology/Loader>`_. Loader doesn't have any parallel processing baked in but a `small change to how it creates it's temporary directory <https://github.com/AstunTechnology/Loader/commit/199e66f7064e341b1365eb10a3d5a572b45b7fdb>`_ allows multiple instance to be ran in parallel each processing a single file at a time. The key component to enable this is `GNU Parallel <http://www.gnu.org/software/parallel/>`_, from the projects homepage:

    GNU parallel is a shell tool for executing jobs in parallel using one or more computers. A job can be a single command or a small script that has to be run for each of the lines in the input. The typical input is a list of files, a list of hosts, a list of users, a list of URLs, or a list of tables. A job can also be a command that reads from a pipe. GNU parallel can then split the input and pipe it into commands in parallel.

The way I've been using Parallel with Loader is to build a list of files to process using ``find`` which is piped to ``parallel`` which handles executing as many processes as there are cores (by default). For example:

.. code-block:: bash

    find /var/data/osmm/ -type f -print0 | \
    parallel -0 python loader.py loader.config "src_dir={}"

Using this approach on an 8 core EC2 server with SSD volumes national OS MasterMap Topography Layer can be loaded over a weekend.

Another example of using ``parallel`` would be to build on the bash one-liner that Tim Sutton posted a while back to `load all natural earth layers into PostGIS in one go <http://linfiniti.com/2012/03/another-bash-one-liner-load-all-natural-earth-layers-into-postgis-in-one-go/>`_. Tim's original command used ``find`` to build a list of files then loops over the list and runs ``shp2pgsql`` for each piping the output to ``psql`` to do the actual load. Here's the original command tweaked slightly to exclude the ``tools`` directory and specify the encoding including timing:

.. code-block:: bash

    time for FILE in `find . -name '*.shp' -not -path "./tools/*"`; do \
    BASE=`basename $FILE .shp`; \
    shp2pgsql -W LATIN1 -s 4326 -I $FILE world.$BASE \
    | psql; done

    real	6m14.569s

The example below is the equivalent using `parallel` which significantly reduces load time:

.. code-block:: bash

    time find . -name '*.shp' -not -path "./tools/*" \
    | parallel "shp2pgsql -W LATIN1 -s 4326 -I {} world.{/.} | psql"

    real	3m11.030s

Again ``find`` is used to build a list of input shapefiles which are piped to ``parallel`` which builds and executes the ``shp2pgsql`` and ``psql`` combination. By default ``parallel`` provides the ``{}`` replacement string for the current argument (file path in this case) and ``{/.}`` which strips the path and extension from when the replacement string is a file path.
