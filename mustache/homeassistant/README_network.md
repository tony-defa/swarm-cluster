https://community.home-assistant.io/t/my-docker-swarm-setup/97230

```sh
# create a macvlan network for each node
# start with the first node
docker network create --config-only --subnet=192.168.50.0/24 --gateway=192.168.50.1 -o parent=eth0 --ip-range 192.168.50.232/29 macvlan_local
# create the network on the second node
docker network create --config-only --subnet=192.168.50.0/24 --gateway=192.168.50.1 -o parent=eth0 --ip-range 192.168.50.240/29 macvlan_local
# create the network on the third node
docker network create --config-only --subnet=192.168.50.0/24 --gateway=192.168.50.1 -o parent=eth0 --ip-range 192.168.50.248/29 macvlan_local
```

```sh
# create the macvlan network on the swarm
docker network create -d macvlan --scope swarm --config-from macvlan_local macvlan_swarm
```
