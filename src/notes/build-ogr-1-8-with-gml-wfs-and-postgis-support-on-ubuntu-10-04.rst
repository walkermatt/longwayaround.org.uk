Build OGR 1.8 with GML, WFS and PostGIS support on Ubuntu 10.04
###############################################################
:date: 2010-12-19 21:06
:category: notes
:tags: Gml, Ogr, Postgis, Wfs

OGR 1.8 introduces support for reading GML with feature attributes expressed as nested elements as found in Ordnance Survey's OS MasterMap as well as support for accessing WFS. This is a brief script for building OGR (GDAL) 1.8 from source as it's not currently released: Download latest daily source export: http://www.gdal.org/daily/ and extract it's contents to a directory you have read, write and execute permissions in (I chose ~/Software/gdal-svn-trunk-2010.12.19) Ensure you have the tools required to build software using ``make``:

.. code-block:: bash

    sudo apt-get install build-essential

Install the development package for Xerces-C:

.. code-block:: bash

    sudo apt-get install libxerces-c-dev

Install the PostgreSQL development tools package:

.. code-block:: bash

    sudo apt-get install libpq-dev

Install curl and the development package:

.. code-block:: bash

    sudo apt-get install curl libcurl4-gnutls-dev

Change to the directory where you extracted the GDAL source (that's ~/Software/gdal-svn-trunk-2010.12.19 for me):

.. code-block:: bash

    cd ~/Software/gdal-svn-trunk-2010.12.19

Run the configure script which prepares the ground before we build GDAL with ``make``. Here we are specifying that we want to configure the build to include xerces support and PostgreSQL (/usr/bin/pg\_config is a script provided with the PostgreSQL development tools package).

.. code-block:: bash

    ./configure --with-xerces=yes --with-pg=/usr/bin/pg_config --with-curl=/usr/bin/curl-config > configure-output.txt

Now we can actually build GDAL/OGR:

.. code-block:: bash

    make > make-output.txt

Providing make did not error GDAL should now be built and ready to use.  You can find the executable utilities such as gdalinfo, ogrinfo, ogr2ogr etc. in the apps directory within the directory that you extracted the GDAL source (~/Software/gdal-svn-trunk-2010.12.19/apps/ogr2ogr for me.); to make it easier to run these utilities it may be worthwhile setting a variable to this path: 

.. code-block:: bash

    GDAL_PATH=~/Software/gdal-svn-trunk-2010.12.19/apps/

It's also worth setting the GDAL\_DATA environment variable so that resources such as coordinate system definitions etc.

.. code-block:: bash

    export GDAL_DATA=$GDAL_PATH../data

You can then use the utilities like so: Translate from GML to ESRI Shape. To parse nested feature attributes you will need to modify the .gfs file generated the first time the GML file is opened. The .gfs file allows you to map GML properties to feature attributes.

.. code-block:: bash

    $GDAL_PATH/ogr2ogr -f 'ESRI Shapefile' . test.gml

Translate GML to PostGIS

.. code-block:: bash

    $GDAL_PATH/ogr2ogr -f PostgreSQL PG:"dbname='postgis' active_schema=mapbase host='localhost' user='fred' password='itscomplicated'" test.gml

List available layers from a WFS

.. code-block:: bash

    $GDAL_PATH/ogrinfo -ro WFS:"http://www.tinyows.org/cgi-bin/tinyows"

Get info about all features in a given layer including coordinates

.. code-block:: bash

    $GDAL_PATH/ogrinfo WFS:"http://www.tinyows.org/cgi-bin/tinyows" tows:world -ro -al

Download all features from a layer and write to a good old ESRI Shape file

.. code-block:: bash

    $GDAL_PATH/ogr2ogr -f 'ESRI Shapefile' . WFS:"http://www.tinyows.org/cgi-bin/tinyows" tows:world

