# Mustache

A tentative at making the stack files more dynamic by trying to create the stack file from a mustache template. This also allows to create multiple stacks from the same template.

Each stack folder should contain a `.mustache` file that contains the structure of the compose file and a `.view.json` file that contains the data to be injected into the template.

## Install mustache

There are several ways to install mustache. Find the way that suits you best by visiting the [mustache github page](https://mustache.github.io/).

## Deploy a stack

The following paragraphs describe the general steps to take when creating a stack from a mustache template. In some cases further perquisites are described in the `README.md`-file of the stack directory.

### 0. Make a decision
Since the templates allows for multiple stacks to be created from the same template, a name for the stack needs to be chosen. The name that will be used for the examples in the following paragraphs is `my-project`. Replace this with the name of your choice.

> The name will be prefixed with '.' in the examples below so that they are ignored by git. This is not necessary if you do not want to commit the stack files to git.

### 1. Environment files
Environment files are handled the same way as in the regular stack files. But should contain the name of the stack in the file name. For example:

```sh
$ cd folder-of-interest/
$ cp example.env .my-project.env
```

### 2. View files
The `.view.json`-file contains the data that will be injected into the mustache template. Create a custom `.view.json`-file for your stack by running the following command:

```sh
$ cd folder-of-interest/
$ cp example.view.json .my-project.view.json
```

Now edit the `.my-project.view.json`-file and configure it according to the cluster.


### 3. Configured `HOST` paths

The `.my-project.view.json`-file may contain paths that need to be created before the execution of the stack. These are properties that start with `host_`. To create these folders, run the following commands:

```sh
$ cd folder-of-interest/
$ cat .my-project.view.json | jq -r '. | to_entries[] | select(.key | startswith("host_")) | .value' | xargs sudo mkdir -p
$ cat .my-project.view.json | jq -r '. | to_entries[] | select(.key | startswith("host_")) | .value' | xargs sudo chown -R :docker
```

> Use the `sudo` command (after the last pipe) for directories that do not reside in your home directory. Omit `sudo` otherwise.
> For NFS configuration: Use `nobody:nogroup` as owner for the created directories with the `chown` command.

### 4. Other steps
To setup the required data, networks and secrets, follow the instructions in the root `README.md`-file and the `README.md`-files of the stack folder.

### 5. Create the stack file from the mustache template
If you have decided to use the mustache template, you need to create the stack file first. This can be done by running the following command:

```sh
$ cd folder-of-interest/
$ mustache .my-project.view.json app.mustache > .my-project.app.yml
```

or deploy the stack directly without creating the intermediate stack file:

```sh
$ cd folder-of-interest/
$ mustache .my-project.view.json app.mustache | env -i $(cat .my-project.env | grep "^[A-Z]" | xargs) docker stack deploy -c - stack-name
```

or omit the `env` part of the command, if there is no `.env`-file associated with the stack:

```sh
$ cd folder-of-interest/
$ mustache .my-project.view.json app.mustache | docker stack deploy -c - stack-name
```
