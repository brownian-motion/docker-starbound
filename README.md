# brownian-motion/starbound

Forked from [morgyn/starbound](https://github.com/Morgyn/docker-starbound)

This is a docker image of the dedicated server for Starbound, using steam.

* [ http://playstarbound.com/ ]
* [ http://store.steampowered.com/app/211820/ ]

The difference between this docker image and others, is that you do not need to store your steam username, password and either disable steamguard or save a steamguard key. The downside is you need to manually update when needed.

This configuration can also be provided 

## Get the image
`docker pull BrownianMotion/starbound`

## Run the image
```sh
docker run --name starbound -p 21025:21025 -v /root/starbound:/starbound BrownianMotion/starbound
```

Replace ``/root/starbound`` with where you wish to store your Starbound installation.

The image contains nothing but the update script and the steamcmd. You will have to first run update.sh to download first

## Run the update script while the image is running
```sh
docker exec -e STEAM_USERNAME=foo -t -i starbound /update.ps1
```

This script will prompt you to for your password (and steamguard if it's required), it will then perform the initial installation.

If it fails or quits for some reason, you can just rerun to complete.

After the installation has completed successfully, the container will stop


## Configure your Starbound server.

Edit your configuration in the installation directory you chose (``.../starbound/storage/starbound_server.config``)

You can also set any config variable as an environment variable with the `STARBOUND_` prefix, e.g. `STARBOUND_serverName`.

[ http://starbounder.org/Guide:Setting_Up_Multiplayer#Advanced_Server_Configuration ]

## Restart the docker image to start the server
`docker run starbound`

## Updating.

With the server still running, run the update script as above. It will quit the server, then begin the update. Like the initial installation, if the update fails or quits for some reason, just run again, it will stop the container when it is successful.

To install mods, run this update command with the `MOD_IDS` variable set:
```sh
docker exec -e STEAM_USERNAME=foo -e MOD_IDS='1234567890,1234567890' -t -i starbound /update.ps1
```

To run with the update, just start the docker image again as above.


## Building
If you prefer to build the image yourself, just clone and build the `main` target:

```sh
# get the repo
git clone https://github.com/BrownianMotion/docker-starbound && cd docker-starbound

# build the image
docker build -t starbound --target main .

# run the image
docker run --name starbound -p 21025:21025 -v /root/starbound:/starbound starbound
```

### Testing
```sh
docker build --target test .
```