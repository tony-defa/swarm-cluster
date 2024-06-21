```yml
http:
 use_x_forwarded_for: true
 trusted_proxies:
   - 127.0.0.1
   - 10.0.0.0/16 # traefik proxy subnet
```


```sh
# run the following command from within the container to get blootooth running
bluetoothctl power on
```