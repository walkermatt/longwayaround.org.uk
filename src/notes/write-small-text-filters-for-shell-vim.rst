Writing small text filters for the shell and Vim
################################################
:date: 2022-06-22 21:56
:category: notes
:tags: vim, bash, sh, python

Text filters are command-line programs that take text as input, transform it then output the results. An example of a common built in text filter is ``sort`` which when passed newline separated text will sort each line:

.. code-block:: bash

    printf 'b\nc\na' | sort

You can write your own text filter scripts; this is an example from my `~/.bin <https://github.com/walkermatt/dotbin>`_ directory which can be used to filter JSON text. It supports pretty printing the output as well as removing any formatting so that the JSON text is all on one line.

``jsonformat``

.. code-block:: python

    #!/usr/bin/env python3

    import sys
    import json
    from optparse import OptionParser


    def main():

        parser = OptionParser()
        parser.add_option('-i', '--indent', dest='indent', type='int', action='store', default=4)
        parser.add_option('-s', '--squash', dest='squash', action='store_true')
        options, args = parser.parse_args()

        if len(args) == 0:
            infile = sys.stdin
            outfile = sys.stdout
        elif len(args) == 1:
            infile = open(args[0], 'rb')
            outfile = sys.stdout
        elif len(args) == 2:
            infile = open(args[0], 'rb')
            outfile = open(args[1], 'wb')
        else:
            raise SystemExit(sys.argv[0] + " [infile [outfile]]")
        try:
            obj = json.load(infile)
        except ValueError as e:
            raise SystemExit(e)
        if options.squash:
            json.dump(obj, outfile)
        else:
            json.dump(obj, outfile, sort_keys=True, indent=options.indent, separators=(',', ': '))
        outfile.write('\n')


    if __name__ == '__main__':
        main()

The Python script makes use of the Python 3 ``json`` package for reading and writing JSON and supports reading from standard input (``stdin``) or a file and writing to standard out (``stdout``) or file.

Assuming a file called ``feature.json`` it can be pretty printed with an indentation of ``2`` spaces to ``stdout`` like so:

.. code-block:: bash

    jsonformat --indent 2 features.json

.. code-block:: json

    {
      "features": [
        {
          "geometry": {
            "coordinates": [
              [
                [
                  -2.407379150390625,
                  52.36302183361385
                ],
                [
                  -2.3258399963378906,
                  52.36302183361385
                ],
                [
                  -2.3258399963378906,
                  52.41488029514571
                ],
                [
                  -2.407379150390625,
                  52.41488029514571
                ],
                [
                  -2.407379150390625,
                  52.36302183361385
                ]
              ]
            ],
            "type": "Polygon"
          },
          "properties": {
            "name": "Wyre Forest"
          },
          "type": "Feature"
        }
      ],
      "type": "FeatureCollection"
    }

Or output with formatting removed:

.. code-block:: bash

    jsonformat --squash features.json

.. code-block:: json

    {"features": [{"geometry": {"coordinates": [[[-2.407379150390625, 52.36302183361385], [-2.3258399963378906, 52.36302183361385], [-2.3258399963378906, 52.41488029514571], [-2.407379150390625, 52.41488029514571], [-2.407379150390625, 52.36302183361385]]], "type": "Polygon"}, "properties": {"name": "Wyre Forest"}, "type": "Feature"}], "type": "FeatureCollection"}


Use in Vim
==========

Assuming the script is in your system path it can then be used from within Vim to filter text within a buffer.

Format program (``formatprg``)
------------------------------

Add the following to your ``.vimrc`` to set ``jsonformat`` as the `format program <https://vimhelp.org/options.txt.html#%27formatprg%27>`_ for JSON files:

.. code-block:: vim

    au FileType json setlocal formatprg=jsonformat

When you have a buffer with a file type of JSON open you can then use ``gq`` followed by a motion to invoke the format program. You can also select lines in visual mode and use ``gq`` to format just those lines.

Execute shell command (``:!``)
------------------------------

It's also possible to select lines in visual mode then call ``jsonformat`` `via the command-line mode <https://vimhelp.org/various.txt.html#%3A%21>`_ (the ``'<,'>`` are inserted for you and represent the range of the currently selected lines):

.. code-block:: vim

    :'<,'>!jsonformat --squash

This approach has the advantage of allowing options to be specified such as ``--squash`` in the above example.
