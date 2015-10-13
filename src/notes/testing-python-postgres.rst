Testing Python & Postgres
#########################
:date: 2015-10-12 21:00
:category: notes
:tags: testing, python, postgres, notes

I recently pulled together `a project to demonstrate testing Python functions that interact with a Postgres database <https://github.com/walkermatt/python-postgres-testing-demo/>`_. I find that this sort of thing crops up occasionally and the project is an attempt to distil the approach. The main points include:

* Creating a fresh temporary database via testing.postgresql prior to running tests
* Setting up the temporary database via a script with required structure (schemas, tables, roles, functions etc.)
* Putting the database into a known state prior to running each individual test (populating tables with known data)
* Inspecting and making assertions about the state of the database once the function being tested has been executed
* Pausing tests using the debugger (:code:`pdb`) to connect to the temporary database (using :code:`db.url()` and :code:`psql <url>`) to inspect it's current state while testing

View the project on GitHub: `walkermatt/python-postgres-testing-demo <https://github.com/walkermatt/python-postgres-testing-demo/>`_.
