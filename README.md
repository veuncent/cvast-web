# Docker build for the CVAST implementation of Arches

Developed by the Center for Virtualization and Applied Spatial Technologies (CVAST),
University of South Florida.

This repository lets you run Arches ([http://archesproject.org/](Link URL)) in a Docker container, alongside containers for Elasticsearch and Postgresql.  

To get started with Docker: [https://www.docker.com/](Link URL)  

**Note**: if you run Docker on **Windows or Mac < version 1.12 **, your Arches app will not run on localhost:8000, but on a different IP address. To find out this ip address, open Docker and type: 

```
#!shell

docker-machine ip
```  
&nbsp;
____________________________________________
### Config

- In the Dockerfiles:  
	* Optionally you can change the ENV variables to your needs  

- In the file 'docker-compose.yml':  
	* Change environment variables to your needs. 
	* If you run this in your development environment, you might wannt to change the mount folder path to your workspace folder  
		* e.g.: - /c/Users/<your Windows user>/Documents/<your repo workspace>/:/<root of your project>  
		This way you can edit code without having to build the Docker image again.
	* Remove the above-mentioned line if you run this in a non-development environment.  
	* **Change the passwords of environment variables PG_PASSWORD and DJANGO_PASSWORD to the passwords you want to set.**

	
**Advanced:**  

- The cvast_arches app contains customizations made by CVAST based on the Arches Hip application. You can continue to build on this app if desired. If you want to start with a clean Arches custom app:  
	* Delete the cvast_arches folder in the root of this repository  
	* In the file 'Dockerfile-web':  
		* Change the environment variable WEB_APP_NAME into the name of your new app  
		* Uncomment these lines (141 and 142):  
			#WORKDIR /${WEB_ROOT}  
			#RUN arches-app create ${WEB_APP_NAME} --app arches_hip  
		Comment these lines out again after first run, as you only need to do this once.
	* Mount your development file system to the Docker container (as explained above), so your new app folder is persisted.

- If you want to run clusters of the same containers (e.g. multiple web containers, perhaps on different host machines), the mount points should be on a folder accessible by all containers, e.g. a shared (network) drive.
	* This is currently not possible with the elasticsearch and db containers, these require some extra configuration. Coming soon...
	
- If you create your own custom app on top of this, you might want to add the uploadedfiles/files path to the .dockerignore file in the root of this repository. This in order to keep these files from taking up space in your Docker image.  

&nbsp;
__________________________________
### Build

From the repository root directory : 
(The first build takes a long time, probably > 30 minutes)

	docker-compose build
&nbsp;	
__________________________________
### Run


	docker-compose.exe up

After the first successful deployment, your host volumes have been initialized for data persistence. 
**For subsequent deployments you should change the environment variable IS_CLEAN_ENV for web, db and elasticsearch to 'false' in docker-compose.yml.**
&nbsp;
__________________________________
### Housekeeping
To clean up unused images and containers run this from the repository root directory: 
	
	./cleanup.sh
&nbsp;
__________________________________
### Persistence
The data of all containers is kept (persisted) in volumes as specified in docker-compose.yml.  

Basically, a 'Named Volume' (or 'relative path') creates a folder on the host machine under /var/lib/docker/volumes.
A volume with an absolute path (like the one that mounts the repository workspace onto the web folder ('/cvast_web') in the container) is stored on that specified absolute path.  

Most important difference: a volume with absolute path is mounted over the folder in the container, hiding everything that was in that container folder. In case of the Named Volume the data present in the container is not hidden.
Read more:  
https://docs.docker.com/engine/tutorials/dockervolumes/  
And specifically: https://docs.docker.com/engine/tutorials/dockervolumes/#/mount-a-host-directory-as-a-data-volume    	
&nbsp;
__________________________________
### Known Issues
- EOL Windows/Unix:
	* Error: When running the containers, certain .sh files are not found, e.g.:  
    elasticsearch_1  |←[0m /bin/sh: 1: /install/es_entrypoint.sh: not found  
	* Cause: Line endings (EOL) are in Windows format  
	* Fix: In Notepad ++ --> Edit --> EOL Conversion --> UNIX/OSX Format --> Save file  

&nbsp;
__________________________________
### Roadmap  
Among other things: 
 
- Make Postgres work in a cluster. Need the right settings for the nodes to communicate with each other.  
- Make Elasticsearch work in cluster. Ibid.

&nbsp;
__________________________________
&nbsp;
# AWS
### Configure AWS

CVAST Arches can be set up in an AWS ECS cluster. We provide a deployment script in ./AWS/deploy/deployAWSTask.sh, 
which is still under construction. At the moment it is written very specificly for CVAST, but it will be made more generic in the future.  

Currently it assumes the following resource names:
- CLUSTER_NAME=${ENVIRONMENT}-cvast-arches-cluster
	e.g. prod-cvast-arches-cluster
- SERVICE_NAME=${ENVIRONMENT}-cvast-arches-${DOCKER_IMAGE}-service
	e.g. acc-cvast-arches-elasticsearch-service
- TASK_FAMILY=${ENVIRONMENT}-cvast-arches-${DOCKER_IMAGE}-task
	e.g. test-cvast-arches-web-task

For further usage information, run .install/AWS/deploy/deployAWSTask.sh --help
&nbsp;
__________________________________
### Deploy to AWS
Copy the files from ./AWS/deploy/dummy-task-definitions to ./AWS/deploy/task-definitions
Change the file prefixes from 'dummy-' to 'your-environment-name-'
Change the endpoints and variable values between <> to your specific values

After the first successful deployment, your host volumes have been initialized for data persistence. For subsequent deployments you should change the environment variable IS_CLEAN_ENV for db and elasticsearch to 'false'.
