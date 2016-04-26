OpenLayers 2 Custom Build
#########################
:date: 2016-04-26 14:00
:category: notes
:tags: openlayer2, notes

A bit of a blast from the past now that OpenLayers 3 has been released but it may be useful for someone who is working on or maintaining an OpenLayer 2 project.

Create a list of OpenLayers 2 classes used within a code base suitable for including in a `custom build profile <http://docs.openlayers.org/library/deploying.html#custom-build-profiles>`_.

.. code-block:: bash

    cd /path/to/your/js/
    grep --ignore-case --recursive --no-filename --only-matching 'new OpenLayers\.[a-z0-9\.]*' | \
    sed -e 's/new //' -e 's/\./\//g' -e 's/$/\.js/' | \
    sort | \
    uniq

Explanation
===========

* Find instances of :code:`new OpenLayers.FOO` in all source files below the current directory using :code:`grep`
* Remove :code:`"new "` from each matching line, replace the dots which separate the parts of the class name with forward slashes and add :code:`.js` to the end to complete the path all using :code:`sed` (each :code:`-e` applies an expression to each line)
* Sort the list with :code:`sort`
* Remove duplicates with :code:`uniq`

Caveats
=======

Vector Renderers
----------------

If you find :code:`OpenLayers/Layer/Vector.js` in the list then the vector rendering classes will need to be included manually:

.. code-block:: cfg

    OpenLayers/Renderer/Canvas.js
    OpenLayers/Renderer/SVG.js
    OpenLayers/Renderer/VML.js

Utility Classes
---------------

If you are using classes such as :code:`OpenLayers.Pixel`, :code:`OpenLayers.LonLat`. You will find that when using the build script you get an error as the source files can not be found as the class names do not match the location in the OpenLayers source. In most cases for these base classes you can simply remove them from the build config file as they will be automatically included as they are referenced by the other classes such as :code:`OpenLayers.Map`.
