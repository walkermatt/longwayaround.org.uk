Custom GeoServer GetFeatureInfo Template
########################################
:date: 2013-10-18 17:24
:category: notes
:tags: geoserver, notes

The default  `GeoServer <http://geoserver.org/>`_ GetFeatureInfo Freemarker template is a simple table and doesn't work very well when displaying the content in a web map popup. It's a common requirement to change the GetFeatureInfo template to an unordered list, to capitalise the title and attribute names. Here is a sample `content.ftl` that does just that and converts any attrubute values starting with `http` into a link:

[gist:id=7052155,file=content.ftl]

See the `GeoServer Freemarker tutorial <http://docs.geoserver.org/stable/en/user/tutorials/freemarker.html>`_ for details of where the content template needs to live. The `Freemaker Documentation <http://freemarker.org/docs/>`_ is comprehensive if you're interested in further customisation.
