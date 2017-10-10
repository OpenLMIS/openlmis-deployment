# RDS configuration

This guide assumes a clean RDS instance has just been created.


1. Setting up PostGIS for RDS

    PostGIS is used by some OpenLMIS services to provide better geographical support.
    Amazon provides a great guide on how to do it under 
    [this link](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Appendix.PostgreSQL.CommonDBATasks.html#Appendix.PostgreSQL.CommonDBATasks.PostGIS). 
    Make sure to execute those instructions in the database containing OpenLMIS schemas, 
    rather than *postgres*.
  
1. Adding UUID extension on RDS.
    Some services require the *uuid-ossp* extension in order to randomly generate UUIDs in SQL. In 
    order to ensure OpenLMIS works properly with RDS, you _need_ to run the following command to 
    install the extension:

    `CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`
