# RDS configuration

## Setting up PostGIS for RDS

If you want to add PostGIS support to your database you need to do some setting up. Amazon provides
a great guide on how to do it under [this link](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS). Make sure to execute those instructions in the database containing OpenLMIS schemas, rather than *postgres*. You may also need to set correct search paths to the schemas you are installing the extensions in and reconnect to the database, depending on the way you are installing them.
