external_url 'http://gitlab.localhost/'
gitlab_rails['initial_root_password'] = File.read('/run/secrets/gitlab_root_password')

# Change to true to enable lfs - enabled by default if not defined
gitlab_rails['lfs_enabled'] = true

# Reduce the number of running workers to the minimum in order to reduce memory usage
puma['worker_processes'] = 2
sidekiq['concurrency'] = 9

# Prometheus monitoring. Turn off, to reduce idle cpu and disk usage
prometheus_monitoring['enable'] = true
prometheus['listen_address'] = 'gitlab:9090'


gitlab_rails['ldap_enabled'] = false
gitlab_rails['prevent_ldap_sign_in'] = false
gitlab_rails['ldap_servers'] = {
    'main' => {
    'label' => 'LDAP',
    'host' =>  'localhost',
    'port' => 389,
    'uid' => 'uid',
    'encryption' => 'plain',
    'verify_certificates' => true,
    'bind_dn' => 'cn=readonly,dc=Example Corp.,dc=example.com',
    'password' => 'readonly',
    'timeout' => 10,
    'active_directory' => false,
    'allow_username_or_email_login' => true,
    'block_auto_created_users' => false,
    'base' => 'dc=Example Corp.,dc=example.com',
    'user_filter' => '',
    'attributes' => {
        'username' => ['uid', 'userid', 'sAMAccountName'],
        'email' => ['mail', 'email', 'userPrincipalName'],
        'name' => 'cn',
        'first_name' => 'givenName',
        'last_name' => 'sn'
    },
    'lowercase_usernames' => false,
    }
}