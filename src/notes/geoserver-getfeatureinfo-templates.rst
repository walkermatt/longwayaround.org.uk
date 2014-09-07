Custom GeoServer GetFeatureInfo Template
########################################
:date: 2013-10-18 17:24
:category: notes
:tags: geoserver, notes

The default  `GeoServer <http://geoserver.org/>`_ GetFeatureInfo Freemarker template is a simple table and doesn't work very well when displaying the content in a web map popup. It's a common requirement to change the GetFeatureInfo template to an unordered list, to capitalise the title and attribute names. Here is a sample `content.ftl` that does just that and converts any attrubute values starting with `http` into a link:

.. code-block:: xml

    <ul>
    <#list features as feature>
    <li><h2>${feature.type.title}</h2>
    <ul>
    <#list feature.attributes as attribute>
        <#if !attribute.isGeometry>
        <li>${attribute.name?replace("_", " ", "i")?cap_first}: 
            <#if attribute.value?starts_with('http')>
            <a href="${attribute.value}">${attribute.value}</a>
            <#else>
            ${attribute.value}
            </#if>
        </li>
        </#if>
    </#list>
    </ul>
    </li>
    </#list>
    </ul>

See the `GeoServer Freemarker tutorial <http://docs.geoserver.org/stable/en/user/tutorials/freemarker.html>`_ for details of where the content template needs to live. The `Freemaker Documentation <http://freemarker.org/docs/>`_ is comprehensive if you're interested in further customisation.
