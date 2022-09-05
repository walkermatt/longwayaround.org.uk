Web Mercator OS Vector Tile API in OpenLayers - Take #2
#######################################################
:date: 2022-09-05 08:05
:category: notes
:tags: javascript, openlayers, vector-tiles, notes

This is an update to my `previous post </notes/web-mercator-os-vector-tile-api-in-openlayers/>`_ on the same subject.

Thanks to `some feedback from Andreas Hocevar <https://twitter.com/ahoce/status/1545409888226099200>`_ and `a pull request I made to ol-mapbox-style <https://github.com/openlayers/ol-mapbox-style/pull/618>`_ adding a Vector Tile layer of Ordnance Survey data from the OS Data Hub to an OpenLayers map in Web Mercator is a little easier than it was `a few months ago </notes/web-mercator-os-vector-tile-api-in-openlayers/>`_ 🎉

The following uses `create-ol-app <https://github.com/openlayers/create-ol-app>`_ to create a basic OpenLayers app, we then add the `ol-mapbox-style <https://github.com/openlayers/ol-mapbox-style/pull/618>`_ package and install the other dependencies:

.. code-block:: shell

    # Create a new OpenLayers app in a folder called os-vt-api-ol
    npx create-ol-app os-vt-api-ol

    # Change to the newly created folder which contains our app
    cd os-vt-api-ol/

    # Install the ol-mapbox-style package from npm
    npm i ol-mapbox-style

    # Install the other dependencies (vite and ol)
    npm i

    # Start the vite local web server which reloads during development (see the "start" script in package.json)
    npm start

Next update the code to add the OS Vector Tile layer:

``main.js``
-----------

.. code-block:: javascript

  import './style.css';
  import { Map, View } from 'ol';
  import VectorTileLayer from 'ol/layer/VectorTile';
  import { transform } from 'ol/proj';
  import { applyStyle } from 'ol-mapbox-style';

  let OS_API_KEY = 'YOUR_OS_API_KEY';

  let OsVtLyr = new VectorTileLayer({
    declutter: true,
  });

  applyStyle(
    OsVtLyr,
    'https://api.os.uk/maps/vector/v1/vts/resources/styles?srs=3857&key=' +
      OS_API_KEY,
    '',
    {
      // Specify the optional transformRequest function which is
      // called before each resource associated with the style
      // is fetched. In this instance we are ensuring the `srs`
      // parameter is set to `3857` (Web Mercator) when fetching
      // each resource (Source, Sprite, Tiles etc.). Full docs at
      // https://github.com/openlayers/ol-mapbox-style#transformRequest
      transformRequest(url, type) {
        url = new URL(url);
        if (!url.searchParams.has('srs')) {
          url.searchParams.append('srs', '3857');
        }
        return new Request(url);
      },
    }
  ).then((e) => {
    // Once the style has been applied set the attribution which is missing
    // from the source document
    OsVtLyr
      .getSource()
      .setAttributions(
        '&copy; <a href="http://www.ordnancesurvey.co.uk/">Ordnance Survey</a>'
      );
  });

  const map = new Map({
    target: 'map',
    layers: [OsVtLyr],
    view: new View({
      center: transform([-2.333029, 52.109524], 'EPSG:4326', 'EPSG:3857'),
      zoom: 14,
    }),
  });

See the comments in the code for an explanation of the steps involved. The you should end up with a map that looks something like this:

.. image:: /files/os-vector-tile-openlayers.png
  :width: 100%
  :alt: OpenLayers map showing styled OS Vector Tiles data for Malvern, UK
