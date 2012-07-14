Convert a directory of TIFFs to greyscale using ImageMagick
###########################################################
:date: 2011-01-07 17:53
:category: notes
:tags: command-line, notes

Change to the directory then run the command:

.. code-block:: bash

    mogrify -colorspace Gray *.tif

