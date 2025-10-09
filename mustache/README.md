# Mustache

A tentative at making the stack files more dynamic by trying to create the stack file from a mustache template. This also allows to create multiple stacks from the same template.

Each stack folder should contain a `.mustache` file that contains the structure of the compose file and a `.view.json` file that contains the data to be injected into the template.

## Install mustache

There are several ways to install mustache. Find the way that suits you best by visiting the [mustache github page](https://mustache.github.io/).

## Prepare view and environment files

The following paragraphs describe the general steps to take when creating a stack from a mustache template. In some cases further prerequisites are described in the `README.md`-file of the stack directory.

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

## Deploy a stack

You can deploy a mustache template stack either by using the provided helper script (recommended) or by following the manual process.

### 🚀 Deploy using the helper script (recommended)

**Run the deployment script**

    ```bash
    deploy-stack <stack-file.mustache> [stack-name]
    ```

    - `<stack-file.mustache>`: your mustache template file (e.g., `wordpress.mustache`)
    - `[stack-name]`: custom stack name; if omitted, the script uses the view filename (without extension)

The script will:

- Detect available view files and prompt for selection (or use default `.view.json`)
- Auto-select corresponding `.env` file based on view file name
- Create any `host_…` folders from view file that don't yet exist and set their group to `docker`
- Prompt you to create secrets used by the stack, if `yd` is installed
- Generate YAML from mustache template and deploy with `docker stack deploy`

---

### Manual deployment process (alternative)

**Create host directories**

The `.my-project.view.json` file may contain paths that need to be created (properties starting with `host_`):

```sh
$ cd folder-of-interest/
$ cat .my-project.view.json | jq -r '. | to_entries[] | select(.key | startswith("host_")) | .value' | xargs sudo mkdir -p
$ cat .my-project.view.json | jq -r '. | to_entries[] | select(.key | startswith("host_")) | .value' | xargs sudo chown -R :docker
```

**Deploy the stack directly**

Having done all the previous steps correctly, you can now deploy a mustache stack by running the following command if an `.env`-file is associated with the stack:

```sh
cd folder-of-interest/
env -i $(cat .my-project.env | grep "^[A-Z]" | xargs) mustache .my-project.view.json app.mustache | docker stack deploy -c - stack-name
```

or omit the `env` part of the command, if there is no `.env`-file associated with the stack:

```sh
cd folder-of-interest/
mustache .my-project.view.json app.mustache | docker stack deploy -c - stack-name
```

**Deploy the stack directly**

Having done all the previous steps correctly, you can now deploy a mustache stack by running the following command if an `.env`-file is associated with the stack:

```sh
cd folder-of-interest/
env -i $(cat .my-project.env | grep "^[A-Z]" | xargs) mustache .my-project.view.json app.mustache | docker stack deploy -c - stack-name
```

or omit the `env` part of the command, if there is no `.env`-file associated with the stack:

```sh
cd folder-of-interest/
mustache .my-project.view.json app.mustache | docker stack deploy -c - stack-name
```
