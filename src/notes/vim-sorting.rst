Sorting lines in (Neo)Vim
#########################
:date: 2024-04-08 08:45
:category: notes
:tags: vim

The built-in Vim :code:`:sort` command supports sorting either all lines in a buffer or a range of lines.

For example to sort a range of lines it's possible to visually select those lines then run :code:`:sort`.

Help docs can be accessed via :code:`:help :sort` and can be viewed `online via vimhelp.org <https://vimhelp.org/change.txt.html#%3Asort>`_.

Example: Sort on pattern
------------------------

It's possible to sort on a specific part of each line by specifying either a search pattern to ignore (the default) or a search pattern that matches the text to search on.

For example to sort the following output from running :code:`du -h --max-depth=1 base_map_cache_EPSG27700/` by the last component of the path:

.. code-block:: text

    1.6G    base_map_cache_EPSG27700/10
    524K    base_map_cache_EPSG27700/04
    25G     base_map_cache_EPSG27700/12
    108K    base_map_cache_EPSG27700/01
    328K    base_map_cache_EPSG27700/02
    3.4M    base_map_cache_EPSG27700/06
    360K    base_map_cache_EPSG27700/03
    69M     base_map_cache_EPSG27700/08
    18M     base_map_cache_EPSG27700/07
    68K     base_map_cache_EPSG27700/00
    1.4M    base_map_cache_EPSG27700/05
    266M    base_map_cache_EPSG27700/09
    6.4G    base_map_cache_EPSG27700/11
    34G     base_map_cache_EPSG27700/

Visually selecting the above in a buffer and typing :code:`:sort /\v\d+$/ r` will result in:

.. code-block:: text

    34G     base_map_cache_EPSG27700/
    68K     base_map_cache_EPSG27700/00
    108K    base_map_cache_EPSG27700/01
    328K    base_map_cache_EPSG27700/02
    360K    base_map_cache_EPSG27700/03
    524K    base_map_cache_EPSG27700/04
    1.4M    base_map_cache_EPSG27700/05
    3.4M    base_map_cache_EPSG27700/06
    18M     base_map_cache_EPSG27700/07
    69M     base_map_cache_EPSG27700/08
    266M    base_map_cache_EPSG27700/09
    1.6G    base_map_cache_EPSG27700/10
    6.4G    base_map_cache_EPSG27700/11
    25G     base_map_cache_EPSG27700/12

The pattern in the command :code:`:sort /\v\d+$/ r`, breaks down as:

* :code:`\v` enables full regular expression support including :code:`$` to match the end of the line
* :code:`\d+$` matches one or more digits at the end of the line

The :code:`r` flag indicates that the sorting should be done based on the search match.
