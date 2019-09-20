MapServer PostGIS Performance
#############################
:date: 2019-09-20 12:00
:category: notes
:tags: mapserver, postgres, postgis, notes

Recently I was looking at improving the performance of rendering a `Space Syntax OpenMapping <https://github.com/spacesyntax/OpenMapping>`_ layer in MapServer. The :code:`openmapping_gb_v1` table is in a PostGIS database with an index on the geometry column. The original MapServer :code:`DATA` configuration looked like this:

.. code-block:: txt

    DATA "wkb_geometry from (select meridian_class_scale * 10 as line_width, * from openmapping.openmapping_gb_v1 order by choice2kmrank) as a using unique fid using srid=27700"

The main thing to note is that the rows are sorted by the :code:`choice2kmrank` value to ensure features are rendered in the correct order (a similar problem as described in `Mapping a road network with MapServer - Understanding the display order <http://mapgears.com/en/blog/archive/2013-03-05-roads_network_mapping>`_).

This SQL results in the following query being executed by MapServer:

.. code-block:: sql

    SELECT "choice2kmrank",
        "line_width",
        encode(ST_AsBinary(ST_Force_2D("wkb_geometry"),'NDR'),'hex') AS geom,
        "fid"
    FROM
    (SELECT meridian_class_scale * 10 AS line_width,
            *
    FROM openmapping.openmapping_gb_v1
    ORDER BY choice2kmrank) AS a
    WHERE wkb_geometry && ST_GeomFromText('POLYGON((441580.992440577 112973.855285226,441580.992440577 115008.987681971,443621.486046148 115008.987681971,443621.486046148 112973.855285226,441580.992440577 112973.855285226))',27700);

There are two issues with the original query performance-wise:

1. Ordering too many rows
-------------------------

The order by clause is within the inner query, so it sorts all rows in :code:`openmapping.openmapping_gb_v1`, not just those that fall within the spatial filter. This is fine for tables with a small number of rows, but has a significant impact for larger tables.

2. Spatial index not being used
-------------------------------

By default MapServer represents the spatial filter as an inline geometry, which often results in Postgres applying the bounding box spatial filter without using the spatial index. This can be seen here when running :code:`EXPLAIN SELECT ...` to generate an execution plan.

Solution
--------

Ideally we want to only sort those rows returned by the spatial filter, as well as having the spatial filter use the spatial index.

MapServer provides a special :code:`!BOX!` placeholder that can be inserted into a SQL query, which dictates where the :code:`ST_GeomFromText('POLGON...` statement appears when MapServer constructs the SQL to execute. At the time of writing the :code:`!BOX!` placeholder is described in `the last example in the PostGIS Data Access documentation <https://mapserver.org/input/vector/postgis.html#data-access-connection-method>`_.

By using the :code:`!BOX!` placeholder we can combine the spatial filter and sort into a single select statement:

.. code-block:: txt

    DATA "wkb_geometry from (select meridian_class_scale * 10 as line_width, * from openmapping.openmapping_gb_v1 where wkb_geometry && !BOX! order by choice2kmrank) as a using unique fid using srid=27700"

Results in MapServer generating:

.. code-block:: sql

    SELECT "choice2kmrank",
        "line_width",
        encode(ST_AsBinary(ST_Force_2D("wkb_geometry"),'NDR'),'hex') AS geom,
        "fid"
    FROM
    (SELECT meridian_class_scale * 10 AS line_width,
            *
    FROM openmapping.openmapping_gb_v1
    WHERE wkb_geometry && ST_GeomFromText('POLYGON((441580.992440577 112973.855285226,441580.992440577 115008.987681971,443621.486046148 115008.987681971,443621.486046148 112973.855285226,441580.992440577 112973.855285226))',27700)
    ORDER BY choice2kmrank) AS a;

To improve the likelihood that the spatial index is used, we can use a technique described by `John Powell <https://gis.stackexchange.com/users/429/john-powell>`_ in `this gis.stackexchange.com answer <https://gis.stackexchange.com/a/253987/6004>`_, which involves moving the geometry creation to a `CTE (Common Table Expression) <https://www.postgresql.org/docs/11/queries-with.html>`_ resulting in the query optimiser having prior knowledge of the geometry which generally results in the spatial index being used.

.. code-block:: txt

    DATA "wkb_geometry from (WITH box (geom) AS (SELECT !BOX! as geom) SELECT fid, wkb_geometry, choice2kmrank, meridian_class_scale * 10 AS line_width FROM openmapping.openmapping_gb_v1, box WHERE wkb_geometry && box.geom ORDER BY choice2kmrank) as a using unique fid using srid=27700"

Results in MapServer generating:

.. code-block:: sql

    SELECT "choice2kmrank",
        "line_width",
        encode(ST_AsBinary(ST_Force_2D("wkb_geometry"),'NDR'),'hex') AS geom,
        "fid"
    FROM (WITH box (geom) AS
            (SELECT ST_GeomFromText('POLYGON((441580.992440577 112973.855285226,441580.992440577 115008.987681971,443621.486046148 115008.987681971,443621.486046148 112973.855285226,441580.992440577 112973.855285226))',27700) AS geom)
        SELECT fid,
                wkb_geometry,
                choice2kmrank,
                meridian_class_scale * 10 AS line_width
        FROM openmapping.openmapping_gb_v1,
            box
        WHERE wkb_geometry && box.geom
        ORDER BY choice2kmrank) AS a;

With this change we're now using the spatial index when applying the spatial filter, then only sorting the filtered rows. In my case the query execution time went from several seconds to less than 500ms with identical results.

Thanks to `Peter Goulborn <https://twitter.com/devsupportman>`_ and `Ian Turton <https://twitter.com/ijturton>`_ for their help getting to the final solution.
