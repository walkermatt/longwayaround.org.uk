Loading PostGIS
###############
:date: 2014-11-20
:category: notes
:tags: command-line, postgis, notes

The options
===========

All support basic options such as specifying table names, schema, SRS etc.

Graphical
---------

`shp2pgsql-gui <http://gothos.info/2014/03/loading-data-into-postgis-shapefiles/>`_
  Graphical interface to shp2pgsql tool shipped with PostGIS to load ESRI Shapefiles via pgAdmin III.

`ogr2gui <https://github.com/zer0infinity/OGR2GUI>`_
  Graphical interface to :code:`ogr2ogr` command line utility. Windows only.

`QGIS DB Manager <http://docs.qgis.org/2.0/en/docs/training_manual/databases/db_manager.html>`_
  Simple database management from QGIS, including creating schemas & tables, moving tables and importing. Supports multiple import formats. Shipped with QGIS.

Proprietary
  Support for PostGIS is now fairly broad within proprietary products including Safe Software's FME, MapInfo Easyloader, ESRI SDE etc. MapInfo and ESRI impose some constraints & conventions including their own metadata tables.

Command Line
------------

`shp2pgsql <http://postgis.refractions.net/documentation/manual-2.0/using_postgis_dbmanagement.html#shp2pgsql_usage>`_
  Fully featured ESRI Shapefile loader, supports specifying tablespace, null geometry handling, encoding etc. Shipped with PostGIS.

`ogr2ogr <http://www.gdal.org/ogr2ogr.html>`_
  Swiss Army Knife of vector translation, supports many input formats and has good support for PostGIS. `PostGIS docs here <http://www.gdal.org/drv_pg.html>`_ and `here <http://www.gdal.org/drv_pg_advanced.html>`_.

`Loader <https://github.com/AstunTechnology/Loader>`_
  Loads GML such as Ordnance Survey data, uses :code:`ogr2ogr` under the hood.

`psql <http://www.postgresql.org/docs/9.3/static/app-psql.html>`_
  Standard command line interface to PostgreSQL used to import from textual formats such as CSV via :code:`COPY`.

Examples
========

shp2pgsql
---------

Load a Shapefile using :code:`shp2pgsql` and :code:`psql`. :code:`shp2pgsql` doesn't load into the database directly but instead outputs SQL which can then be loaded via :code:`psql`. This example pipes the SQL output by :code:`shp2pgsql` to stdout to :code:`psql` which executes it against the specified database.

.. code-block:: bash

    shp2pgsql -W LATIN1 \
                -s 4326 \
                -I natural_earth_vector/10m_cultural/ne_10m_admin_0_countries.shp \
                ne.ne_10m_admin_0_countries \
            | psql -U loader -d postgis

- http://prj2epsg.org/search

ogr2ogr -f PostgreSQL
---------------------

Load an equivalent Shapefile into PostGIS using :code:`ogr2ogr`.

.. code-block:: bash

    ogr2ogr -f PostgreSQL \
            PG:'dbname=postgis user=loader active_schema=ne' \
            natural_earth_vector/10m_cultural/ne_10m_time_zones.shp \
            -nlt PROMOTE_TO_MULTI

Tips
====

Use COPY for Speed
------------------

When loading large quantities of data both :code:`shp2pgsql` and :code:`ogr2ogr` support loading via PostgreSQL Dump format. This involves bulk loading of rows in a textual CSV like format using the :code:`COPY` command which can be much quicker than :code:`INSERT` statement.

Enabling Dump format with :code:`shp2pgsql` is as simple as specifying the :code:`-D` flag (:code:`shp2pgsql -D ...`).

For :code:`ogr2ogr` use the :code:`PGDump` output format with the :code:`PG_USE_COPY` config set to :code:`YES`. The are a number of layer creation (:code:`-lco`) and config options detailed on the `PGDump driver page <http://www.gdal.org/drv_pgdump.html>`_.

.. code-block:: bash

    ogr2ogr -f PGDump \
            --config PG_USE_COPY YES \
            -lco schema=ne \
            -lco create_schema=off \
            /vsistdout/ \
            natural_earth_vector/10m_cultural/ne_10m_admin_1_states_provinces_shp.shp \
            -nlt PROMOTE_TO_MULTI \
            | psql -U loader -d postgis

When loading multi file datasets such as Ordnance Survey `OSMM Topography Layer <http://www.ordnancesurvey.co.uk/business-and-government/products/topography-layer.html>`_ or `VectorMap Local <http://www.ordnancesurvey.co.uk/business-and-government/products/vectormap-local.html>`_ the general approach is:

* Create schema and empty tables
* Load each source file via COPY
* Create indexes, vacuum etc.

An example of this workflow for VectorMap Local can be found in the `Loader repository <https://github.com/AstunTechnology/Loader/tree/master/extras/ordnancesurvey/vml/pgdump>`_. Deferring the creation of indexes can also improve performance significantly as it avoids the database continually rebuilding the indexes during load. In this instance the :code:`ogr2ogr` command might look like:

.. code-block:: bash

    ogr2ogr --config PG_USE_COPY YES \
            -lco schema=ne \
            -lco create_schema=off \
            -lco create_table=off \
            -lco spatial_index=off \
            -f PGDump \
            /vsistdout/ \
            /path/to/source.gml


A benefit of this approach is that you can also fine tune the column types and provide support for date fields which :code:`ogr2ogr` doesn't natively understand.

Parallel Processing
-------------------

Databases are designed to handle lots of concurrent activity and can easily handle more than one process loading data at the same time. Often load performance can be improved by running several :code:`shp2pgsql` or :code:`ogr2ogr` processes at a time. This can be done manually but for large datasets this becomes a pain, lucky on \*unix systems we have `GNU Parallel <http://www.gnu.org/software/parallel/>`_ which can automate it for use. A `previous post <../gnu-parallel-all-the-things/>`_ has covered loading with GNU Parallel in more detail but it fits well with this discussion.

The :code:`parallel` command is very flexible and can take some time to understand but a simple 

In a previous post I provided an example of loading all Natural Earth vectors using :code:`shp2pgsql` so this time lets do the same with :code:`ogr2ogr`:

.. code-block:: bash

    time find natural_earth_vector/10m_physical/ -name '*.shp' \
        | parallel "ogr2ogr -f PGDump \
                        --config PG_USE_COPY YES \
                        -lco schema=ne \
                        -lco create_schema=off \
                        /vsistdout/ {} \
                        -nlt PROMOTE_TO_MULTI | psql -U loader -d postgis"

Load Geometry with COPY
-----------------------

If you have data in a delimited format such as CSV or TSV you can load it via COPY and have PostgreSQL create geometries on the fly by expressing the geometry as WKT or EWKT in your text file. The steps are very similar to those outlined above when using COPY:

* Create table with a geometry column
* Load source file via COPY
* Create indexes, vacuum etc.

As an example lets load a CSV with details of WMS requests with the bounding box expressed as EWKT:

.. code-block:: bash

    cat requests1.csv
    2014-10-20 06:33:24,elmbridge,wms,"SRID=27700;POLYGON((516601 163293, 516729 163293, 516729 163421, 516601 163421, 516601 163293))"
    2014-10-20 06:33:32,surrey,wms,"SRID=27700;POLYGON((492801 166401, 499201 166401, 499201 172801, 492801 172801, 492801 166401))"
    2014-10-20 06:38:09,exactrak,wms,"SRID=27700;POLYGON((206848 67200, 206976 67200, 206976 67328, 206848 67328, 206848 67200))"
    ...

    psql -U loader -d postgis
    drop table if exists requests;
    create table requests(reqtime timestamp, org text, service text, bbox geometry);
    \copy requests FROM 'requests1.csv' DELIMITER ',' CSV;
    select populate_geometry_columns();

