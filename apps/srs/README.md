# SRS

SRS is a simple, high efficiency and realtime video server, supports RTMP, WebRTC, HLS, HTTP-FLV, SRT, MPEG-DASH and GB28181. Oryx is an all-in-one, out-of-the-box, and open-source video solution for creating online video services, including live streaming and WebRTC, on the cloud or through self-hosting.

### `srs.yml`
Contains the SRS server.

## Perquisites
### Storage
A centralized storage solution is not required.

### Service dependencies
Mandatory stacks are:
- `system/traefik.yml`

### Create pre-configured data folder
Copy the `example.conf` to create your custom SRS configuration. The configuration file is the default configuration for the SRS server and should fit basic needs.

```sh
$ cp example.conf .conf
```

Edit the newly created `.conf` file to fit your needs. See [SRS Documentation](https://ossrs.net/lts/en-us/docs/v5/category/main-features) for further information.

### Create docker secrets
No docker secrets are required.

### Create network
No network needs to be created.

## Other notes
No notes