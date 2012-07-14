Recursively delete empty directories
####################################
:date: 2011-03-28 10:31
:category: notes
:tags: command-line, notes

To recursively delete all empty directories from the command prompt in Windows. Open command prompt and change to the desired directory then enter the following:

.. code-block:: bash

    for /F "tokens=*" %f in ('dir /AD /S /B ^| sort /R') do echo rd "%f"

This command generates a list of all directories and sub directories below the current directory in bare format (just the path) sorted in reverse order. The remove directory command (rm) is then called for each item in the list. The rm command will only delete empty directories so those directories containing files or other directories will not be deleted.
