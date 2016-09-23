Scripts in this directory are meant to be ran in Jenkins.

These scripts **won't** work out of the box in a dev's local machine, to make them work, you need a few files that are present in Jenkins but not in your local clone of this repo:

1.  The .env file

    This file is present in Jenkins. It is copied to the workspace of a deployment job(either Jenkins slave or master) every time that job is ran.

    This file is **not** included in this repo because the db credentials could be different for different deployment environments. The default .env file that is used during development and CI is open in github, making it not suitable for deployment purposes. 

2.  The cert files for remotely controlling docker daemon deployment target

    These files should not be included in this public repo for obvious reasons.
    
    Similar to the .env file, they are also present in Jenkins and copied to a deployment job's workspace(either Jenkins slave or master) every time it is ran.
     
To get these files, you need to be **Jenkins admin**.