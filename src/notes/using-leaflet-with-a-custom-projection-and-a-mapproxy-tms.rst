Using Leaflet with a custom projection and a MapProxy TMS
#########################################################
:date: 2012-07-02 21:06
:category: notes
:tags: leaflet, mapproxy

**Update 2014-05-15** For examples of displaying a Web Map Service (WMS) layer
in a custom projection (EPSG:27700) within Leaflet and OpenLayers 3 (ol3) see:
`astun-leaflet-examples
<https://github.com/AstunTechnology/astun-leaflet-examples>`_ and
`astun-ol3-examples <https://github.com/AstunTechnology/astun-ol3-examples>`_.

**Update 2012-12-18** I've update the `Gist <https://gist.github.com/3034742>`_
to reflect changes in v0.4 of Leaflet, in particular the fact that the
scale function now belongs to the CRS object instead of the Map and the
way that the TileLayer scheme is specified has changed to simply ``tms: true``.

`Leaflet <http://leaflet.cloudmade.com/>`_ is a lightweight JavaScript
slippy map client well suited to use on mobile devices. It’s seen as an
alternative to `OpenLayers <http://openlayers.org/>`_ but takes a
different approach focusing on a small easy to use set of features.

By default Leaflet allow you to display a map in one of the common
projections used to display tiles in the Google and
`OSM <http://www.openstreetmap.org/>`_ tile schemes and the vast
majority of examples you see use these. It is however possible to use
another projection such as a local projection like British National Grid
thanks to `Proj4Leaflet <https://github.com/kartena/Proj4Leaflet>`_
which allows you to provide a `Proj4 <http://trac.osgeo.org/proj/>`_
projection definition and Transformation and scale functions which map
projected coordinates to grid coordinates at a given zoom.

Setting up the definition is straight forward thanks to
`spatialreference.org <http://spatialreference.org>`_ which allows you
to look-up most projections and their definitions. In my case the
Transformation and scale functions also turned out to be simple after a
little trial and error.

I’ve been using a TMS layer provided by one of the MapProxy instances
that form part of Astun Data Services, the configuration of which was as
simple as providing a URL template and setting the ``TileLayer`` scheme
to ``tms``.

I’ve posted an example JavaScript snippet as a GitHub Gist with some
notes here:
`https://gist.github.com/3034742 <https://gist.github.com/3034742>`_
