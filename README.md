Redshift UDF Harness
====================

AWS Redshift recently announced support Python-based User Defined Functions. This repository
contains SQL for many helpful Redshift UDFs, and the scripts for generating and testing
those UDFs.

If you'd like to contribute more UDFs, please send us a pull request or contact us
over at [Periscope.io](https://www.periscope.io)

Usage
-----
The scripts require Ruby. To connect to your cluster to add or test UDFs, you'll need the
the `pg` gem and the following vars in your env or in the config.yaml:

* `UDF_CLUSTER_HOST` -- host of your Redshift cluster, e.g. `my-cluster.us-west-2.redshift.amazonaws.com`
* `UDF_CLUSTER_PORT` -- cluster's db port, e.g. `5439`
* `UDF_CLUSTER_DB_NAME` -- database name, e.g. `master`
* `UDF_CLUSTER_USER` -- database user, e.g. `read-write-user`
* `UDF_CLUSTER_PASSWORD` -- database user's password

Running the main file `udf.rb` without args shows how to use it:

    Usage:
      ruby udf.rb <action> [udf_name]

    Actions:
      load    Loads UDFs into your database
      drop    Removes UDFs from your database
      test    Runs UDF unit tests on your database
      print   Pretty-print SQL for making the UDFs

    Examples:
      ruby udf.rb load
      ruby udf.rb drop harmonic_mean
      ruby udf.rb test json_array_first
      ruby udf.rb print

We look forward to bug reports, UDF requests, and general feedback :)
