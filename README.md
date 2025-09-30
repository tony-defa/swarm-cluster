# Swarm Cluster
A set of docker compose files describing how the server applications should run. Clone this project to one of the master nodes of the cluster and configure according to this documentation.

## Create docker swarm
Follow the steps described here: [Swarm Tutorial: Create a Swarm](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)

## Project structure
The structure is divided into different categories. These are described in the following paragraphs. Each category should contain a `README.md`-file describing the stacks within the category.

### System
This contains system relevant services.

### Apps
These are private or publicly obtained apps that add to the value of the cluster.

### Mustache
A tentative at making the stack files more dynamic by trying to create the stack file from a mustache template. This also allows to create multiple stacks from the same template.

### Jobs
Tasks or jobs can be stored here.

## Preparing the stack

There are a few general steps necessary to deploy a stack. In some cases further prerequisites are described in the `README.md`-file of the stack directory.

The following paragraphs describe the general steps to take when starting a stack.

### 1. Environment files
Folders may contain an `example.env` file that requires some attention before a stack can be deployed. If such a file is present in the folder, run the following command first:

```sh
cd folder-of-interest/
cp example.env .env
```

Now the newly created file needs to be edited and configured according to the cluster. 

### 2. Copy data folder
For a service to run properly, it might be necessary to copy or create a pre-configured data folder to the host path location defined in the `.env`-file. Find the instructions for this step in the `README.md` file of the stack. In that case create the data folder as described [below](#manual-deployment-process-alternative).

### 3. Create docker secrets
In terms of Docker Swarm services, a secret is a blob of data, such as a password, SSH private key, SSL certificate, or another piece of data that should not be transmitted over a network or stored unencrypted in a Dockerfile or in your application’s source code. You can use Docker secrets to centrally manage this data and securely transmit it to only those containers that need access to it.

To create a docker secret simply use the following command.

```sh
printf "someSecret" | docker secret create <name_of_secret> -
```

### 4. Create networks
It may be necessary to create one or more docker networks to run a stack. If this is the case, you'll find the instruction in the `README.md` of the stack folder.

## Deploying a stack

You can deploy a stack either by using the provided helper script (recommended) or by following the manual process.


>### One-time script installation (recommended)
>
>To simplify deployments and automate common pre-deployment steps (like handling `.env` files and `HOST_` paths), install the `deploy-stack` script once on your manager node:
>
>```bash
>sudo cp deploy-stack.sh /usr/bin/deploy-stack
>sudo chmod +x /usr/bin/deploy-stack
>```
>
>Make sure `deploy-stack` is accessible in your PATH (e.g., `/usr/bin`) so you can run it from any directory.


### 🚀 Deploy using the helper script (recommended)

**Run the deployment script**

   ```bash
   deploy-stack <stack-file.yml|stack-file.mustache> [stack-name]
   ```

   - `<stack-file.yml|stack-file.mustache>`: your compose file (e.g., `spec-proxy.yml` or `wordpress.mustache`)
   - `[stack-name]`: custom stack name; if omitted, the script uses the filename (without extension)

The script will:

- Detect and parse `.env` if present in the stack directory
- Create any `HOST_…` folders that don’t yet exist and set their group to `docker`
- Prompt you to create secrets used by the stack.
- Deploy the stack with `docker compose ... config | docker stack deploy ...`

---

### Manual deployment process (alternative)

**Create Configured `HOST` paths**

The `.env`-file may contain paths that need to be created before the execution of the stack. These are variables that start with `HOST_`. To create these folders, run the following commands:

```sh
cd folder-of-interest/
cat .env | grep "^HOST_[A-Z]" | cut -d'=' -f2 | xargs sudo mkdir -p
cat .env | grep "^HOST_[A-Z]" | cut -d'=' -f2 | xargs sudo chown -R :docker 
```

> Use the `sudo` command (after the last pipe) for directories that do not reside in your home directory. Omit `sudo` otherwise.
> For NFS configuration: Use `nobody:nogroup` as owner for the created directories with the `chown` command.

**Finally deploy the stack**

Having done all the previous steps correctly, you can now deploy a stack by simply running the following command, if an `.env`-file is associated with the stack :

```sh
cd folder-of-interest/
env -i $(cat .env | grep "^[A-Z]" | xargs) docker stack deploy -c stack-file.yml stack-name
```

or omit the `env` part of the command, if there is no `.env`-file associated with the stack:

```sh
cd folder-of-interest/
docker stack deploy -c stack-file.yml stack-name
```
