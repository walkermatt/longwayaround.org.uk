Read-only Postgres database
###########################
:date: 2015-09-08 13:00
:category: notes
:tags: postgres, postgis, notes

There are times when I've needed to effectively make a Postgres database read-only, for example after loading or updating reference data. In the past I've revoked permissions from database roles to achieve this but as `this post on the PostgreSQL list states, it's possible to do so by making all transactions against the database read-only by default <http://www.postgresql.org/message-id/5fe0d78bda51d7176940fb8e78739b54@biglumber.com>`_.

For example assuming I have an :code:`osdata` database, I can alter it to set :code:`default_transaction_read_only` (`docs <http://www.postgresql.org/docs/9.4/static/runtime-config-client.html#GUC-DEFAULT-TRANSACTION-READ-ONLY>`_) to :code:`true` which will make future transitions read-only regardless of which login role connects:

.. code-block:: bash

    ALTER DATABASE osdata SET default_transaction_read_only = true;

As the name implies setting :code:`default_transaction_read_only` to :code:`true` only sets transactions to be read-only by default, a user can override or unset the setting on a per-session basis e.g. :code:`set default_transaction_read_only = false;`.
