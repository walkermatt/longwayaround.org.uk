Greyscale maps with MapServer
#############################
:date: 2012-02-02 21:31
:category: notes
:tags: Mapserver

There have been a few times in the past (such as when I was preparing the base mapping for `My Wycombe`_) when I've wanted to create greyscale base mapping using `MapServer`_. Previously I've experimented with various processing options for raster images (with varying degrees of success), converting the source images using `ImageMagick`_ and converting colour RGB values to their greyscale equivalent for vector features and it's generally been time consuming.  Today the requirement came up again and I discovered a far simpler option: specifying a greyscale palette as an OUTPUTFORMAT FORMATOPTION.  The palette simply contains grey values from 0,0,0 (black) to 255,255,255 (white) and all values in between. MapServer then does the job of converting the colours for your source data into their greyscale equivalents.

In the map file specify an `OUTPUTFORMAT`_ that used a specific palette:

::


        # Specify a plain PNG output with a

        # greyscale palette

        IMAGETYPE "AGG_PNG"

        OUTPUTFORMAT

            NAME  "AGG_PNG"

            DRIVER  "AGG/PNG"

            MIMETYPE "image/png"

            IMAGEMODE "RGB"

            EXTENSION "png"

            FORMATOPTION "INTERLACE=OFF"

            FORMATOPTION "PALETTE_FORCE=ON"

            FORMATOPTION "PALETTE=grey.txt"

        END

Snippet from the palette file (`download the full version`_):

::


        0,0,0

        1,1,1

        2,2,2

        --- you get the idea ---

        253,253,253

        254,254,254

        255,255,255

BTW I used the following Python to generate the values for the palette:

.. code-block:: python



    for i in range(0,256):

        print '%i,%i,%i' % (i,i,i)

.. _My Wycombe: http://mywycombe.wycombe.gov.uk/?tab=2
.. _MapServer: http://mapserver.org
.. _ImageMagick: www.imagemagick.org
.. _OUTPUTFORMAT: http://mapserver.org/mapfile/outputformat.html
.. _download the full version: http://longwayaround.org.uk/wordpress/wp-content/uploads/2012/02/grey.txt
