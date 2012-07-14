Disaggregate MultiLineStrings using ST_Dump PostGIS
###################################################
:date: 2011-11-24 21:39
:category: notes
:tags: Postgis

PostGIS the spatial extension to the PostgreSQL database provides a host of functions for querying, creating and manipulating geometries within the database. ST\_Dump allows you to disaggregate collection and multi geometries such as MultiPolygon and MultiLineSting easily. The example below demonstrates starting with a table that contains one row with a MultiLineString geometry and another with a LineString and running a query to disaggregate returning three rows all with a LineString geometry.

Create a table for our demo data:

.. code-block:: sql

    CREATE TABLE complex

    (

       id serial, 

       "name" text,

       geom geometry

    );

Insert one row with a MultiLineString with two parts ('Bob') and another with a single LineString ('Harry')

.. code-block:: sql

    INSERT INTO complex (name, geom)

      VALUES (

        'Bob',

        ST_GeomFromEWKT('MULTILINESTRING((498376.89 651569.6,498372.28 651571.89),(498372.28 651571.89,498371.77 651576.05))')

      );



    INSERT INTO complex (name, geom)

      VALUES (

        'Harry',

        ST_GeomFromEWKT('LINESTRING(598376.89 751569.6,398372.75 658771.03)')

      );

Query to show we have two rows one of which has a MultiLineString geometry:

.. code-block:: sql

    SELECT *, ST_GeometryType(geom) as geom_type, ST_AsEWKT(geom) as geom_wkt from complex;

Results:

+----+-------+-----------------------------+---------------------+-----------------------------------------------------------------------------------------------------+
| id | name  | geom                        | geom\_type          | geom\_wkt                                                                                           |
+====+=======+=============================+=====================+=====================================================================================================+
| 1  | Bob   | 010500000002000000010200... | ST\_MultiLineString | MULTILINESTRING((498376.89 651569.6,498372.28 651571.89),(498372.28 651571.89,498371.77 651576.05)) |
+----+-------+-----------------------------+---------------------+-----------------------------------------------------------------------------------------------------+
| 2  | Harry | 0102000000020000007B14AE... | ST\_LineString      | LINESTRING(598376.89 751569.6,598372.28 751571.89)                                                  |
+----+-------+-----------------------------+---------------------+-----------------------------------------------------------------------------------------------------+

Use the ST\_Dump function to split the row with a MultiLineString into two rows each with a LineString and generate a decimal id composed of the original rows id and the LineString's position in the MultiLineString as the fractional part so that each row still has a unique id that's derived from it's original id:

.. code-block:: sql

    SELECT

      COALESCE((simple.id || '.' || simple.path[1]::text)::float, simple.id) as id,

      simple.name,

      simple.simple_geom as geom,

      ST_GeometryType(simple.simple_geom) as geom_type,

      ST_AsEWKT(simple.simple_geom) as geom_wkt

    FROM (

      SELECT

        dumped.*,

        (dumped.geom_dump).geom as simple_geom,

        (dumped.geom_dump).path as path

      FROM (

        SELECT *, ST_Dump(geom) AS geom_dump FROM complex

      ) as dumped

    ) AS simple;

Results:

+-----+-------+-----------------------------+----------------+-----------------------------------------------------+
| id  | name  | geom                        | geom\_type     | geom\_wkt                                           |
+=====+=======+=============================+================+=====================================================+
| 1.1 | Bob   | 010200000002000000F6285C... | ST\_LineString | LINESTRING(498376.89 651569.6,498372.28 651571.89)  |
+-----+-------+-----------------------------+----------------+-----------------------------------------------------+
| 1.2 | Bob   | 010200000002000000EC51B8... | ST\_LineString | LINESTRING(498372.28 651571.89,498371.77 651576.05) |
+-----+-------+-----------------------------+----------------+-----------------------------------------------------+
| 2   | Harry | 0102000000020000007B14AE... | ST\_LineString | LINESTRING(598376.89 751569.6,598372.28 751571.89)  |
+-----+-------+-----------------------------+----------------+-----------------------------------------------------+

