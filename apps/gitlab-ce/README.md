# GitLab

GitLab is an open source end-to-end software development platform with built-in version control, issue tracking, code review, CI/CD, and more.

### `gitlab.yml`
Contains the GitLab application and a script to create backups.

### `gitlab-runner.yml`
Starts a gitlab-runner instance and a second throw away gitlab-runner instance that registers the first runner and then shuts down.

## Perquisites
### Storage
A centralized storage solution is required.

### Service dependencies
`gitlab.yml` requires the following services to run:
- `system/monitoring.yml`
- `system/traefik.yml`
- `apps/openldap/openldap.yml`: Optional: If available configure LDAP in `rb` file.

`gitlab-runner.yml` requires the following services to run:
- `gitlab.yml`: Wait for the stack to fully start before running the `gitlab-runner.yml` stack. Read more in [this section](#runner-environment-variables)

### Create pre-configured data folder
Copy the `example.rb` to create your custom GitLab configuration.

```sh
$ cp example.rb .rb
```

Edit the newly created `.rb` file to fit your needs. See [GitLab Documentation](https://docs.gitlab.com/omnibus/settings/) for further information.

### Create docker secrets
Create the following docker secrets to configure the startup passwords.

- `gitlab_root_password`: The initial root password for the `root` user

### Create network
A network named `gitlab_network` is automatically created when deploying the `gitlab.yml` stack. 

> Notice: The network `gitlab_network` is attached to the `gitlab-runner.yml` stack, when deploying the runner. In order for the runner stack to select the right network, the `gitlab.yml` stack needs to be called `gitlab`.

## Other notes
### Runner environment variables
In order for the runner stack to register to the gitlab instance, a token is required. This can be obtained from the GitLab instance after it has fully started. See [how to obtain a token here](https://docs.gitlab.com/runner/register/index.html). The token can then be added to the `RUNNER_AUTHENTICATION_TOKEN` variable in the `.env` file. Having done that a runner instance can be started by deploying the `gitlab-runner.yml` stack.

### Creating backups
Backups are created according to the `BACKUP_FREQUENCY` environment variable and are retained for the amount of seconds configured with `gitlab_rails['backup_keep_time']` in the omnibus configuration file. 

### Restore backup
To restore a backup simply deploy the `gitlab` stack with an empty data volume. GitLab will then start with a fresh install. After that follow the instruction from the official documentation: https://docs.gitlab.com/ee/raketasks/restore_gitlab.html

### The issue with backups on a schedule
Sadly the recommended way to schedule the backups for GitLab is to create a cronjob on the host where the instance is running. This can be difficult in a swarm cluster with multiple nodes, since it is difficult to predict where the instance will end up.

To get around this obstacle the backup service will run on each node and try to detect if the `gitlab` service is running on the current node and do the backup and fails otherwise.

### Known Issues
- The runner does not unregister when removing the stack.
