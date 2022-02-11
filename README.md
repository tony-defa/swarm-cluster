# Swarm Cluster

A set of docker compose files describing how the server applications should run. Clone this project to one of the master node of the cluster and configure according to this documentation.

## Create docker swarm
Follow the steps described here: https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/

## Project structure

The structure is divided into different categories. These are described in the following paragraphs. Each category should contain a `README.md`-file describing the stacks within the category.

### System
This contains system relevant services.

### Apps 
These are private or publicly obtained apps that add to the value of the cluster.

### Jobs
Tasks or jobs can be stored here.

## Deploy a stack

There are a few general steps necessary to deploy a stack. In some cases further perquisites are described in the `README.md`-file of the stack directory.

The following paragraphs describe the general steps to take when starting a stack.

### 1. Environment files
Folders may contain an `example.env` file that requires some attention before a stack can be deployed. If such a file is present in the folder, run the following command first:

```sh
$ cd folder-of-interest/
$ cp example.env .env
```

Now the newly created file needs to be edited and configured according to the cluster. 

### 2. Configured `HOST` paths

The `.env`-file may contain paths that need to be created before the execution of the stack. These are variables that start with `HOST_`. To create these folders, run the following commands:
No pre-configured data folder available.
```sh
$ cd folder-of-interest/
$ cat .env | grep "^HOST_[A-Z]" | cut -d'=' -f2 | xargs sudo mkdir -p
$ cat .env | grep "^HOST_[A-Z]" | cut -d'=' -f2 | xargs sudo chown -R :docker 
```

> Use the `sudo` command (after the last pipe) for directories that do not reside in your home directory. Omit `sudo` otherwise.
> For NFS configuration: Use `nobody:nogroup` as owner for the created directories with the `chown` command.

### 3. Copy data folder
For a service to run properly, it might be necessary to copy or create a pre-configured data folder to the host path location defined in the `.env`-file. Find the instructions for this step in the `README.md` file of the stack.

### 4. Create docker secrets
In terms of Docker Swarm services, a secret is a blob of data, such as a password, SSH private key, SSL certificate, or another piece of data that should not be transmitted over a network or stored unencrypted in a Dockerfile or in your application’s source code. You can use Docker secrets to centrally manage this data and securely transmit it to only those containers that need access to it.

To create a docker secret simply use the following command.

```sh
printf "someSecret" | docker secret create <name_of_secret> -
```

### 5. Create networks
It may be necessary to create one or more docker networks to run a stack. If this is the case, you'll find the instruction in the `README.md` of the stack folder.

### 6. Finally deploy the stack
Having done all the previous steps correctly, you can now deploy a stack by simply running the following command, if an `.env`-file is associated with the stack :

```sh
$ cd folder-of-interest/
$ env $(cat .env | grep "^[A-Z]" | xargs) docker stack deploy -c stack-file.yml stack-name
```

or omit the `env` part of the command, if there is no `.env`-file associated with the stack:

```sh
$ cd folder-of-interest/
$ docker stack deploy -c stack-file.yml stack-name
```
