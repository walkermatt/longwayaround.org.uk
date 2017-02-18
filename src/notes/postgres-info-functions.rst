Postgres Information Functions
##############################
:date: 2017-02-18 07:55
:category: notes
:tags: postgres, notes

Postgres contains a wealth of functions that provide information about a database and the objects within. The `System Information Functions of the official documention <https://www.postgresql.org/docs/current/static/functions-info.html/>`_ provides a full list. There are a huge number of functions covering a whole host of info from the current database session, privileges, function properties.

Examples
========

Find an objects oid
-------------------

A lot of the info functions accept the `Object Identifier Type <https://www.postgresql.org/docs/current/static/datatype-oid.html/>`_ for objects in the database. This can be obtained by casting to :code:`regclass` (also described in the  `oid docs <https://www.postgresql.org/docs/current/static/datatype-oid.html/>`_) then to :code:`oid`:

.. code-block:: sql

    select 'schema_name.relation_name'::regclass::oid;

Where :code:`relation_name` is a table, view, index etc.

View definition
---------------

.. code-block:: sql

    select pg_get_viewdef('schema_name.view_name'::regclass::oid);

Or in :code:`psql` you can use one of the built in commands:

.. code-block:: sql

    \d+ schema_name.view_name

Function definition
-------------------

Returns the function definition for a given function. Many built-in functions don't reveal much due to them not being written in SQL but for those that are you'll get the complete create function statement. For example to view the definition of the PostGIS :code:`st_colormap` function:

.. code-block:: sql

    select pg_get_functiondef('st_colormap(raster, integer, text, text)'::regprocedure);

Privileges
----------

A `whole host of functions exist to determine privileges for schemas, tables, functions etc. <https://www.postgresql.org/docs/current/static/functions-info.html#FUNCTIONS-INFO-ACCESS-TABLE/>`_ Some examples:

Determine if the current users can select from a table:

.. code-block:: sql

    select has_table_privilege('schema_name.relation_name', 'select');

Note: The docs state that "multiple privilege types can be listed separated by commas, in which case the result will be true if any of the listed privileges is held". This means that in order to test a number of privileges it is normally better to test each privilege individually as :code:`select has_table_privilege('schema_name.relation_name', 'select,update');` would return :code:`t` even if only :code:`select` is supported.

Determine if a user can use a schema:

.. code-block:: sql

    select has_schema_privilege('schema_name', 'usage');
