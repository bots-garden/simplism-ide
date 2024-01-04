# Simplism IDE

## What is Simplism IDE?

Simplism IDE is a "local cloud development environment" (*) to develop [Extism](https://extism.org/) plug-ins for the [Simplism](https://github.com/bots-garden/simplism#simplism-a-tiny-http-server-for-extism-plug-ins) HTTP server without the need to install all the "complicated things".

> (*) but you can use it remotely

The current version of Simplism is: `simplism v0.0.9 🐳 [spouting whale]`

## How to run it?

### With Docker Compose

- The parameters (architecture and version of the installed softwares) are defined in the `.env`.
  > I'm using a MacBook, so it's an arm platform, but you should be able to modifiy the settings for your platform (in th future I will provide more settings samples).

1. You need [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/)
2. Next, clone this repository: `git clone https://github.com/bots-garden/simplism-ide.git`
3. Run `docker compose up` into the `simplism-ide` directory (if you change something into `.docker/compose/Dockerfile`, you will need to run `docker compose build`)
4. Go to: http://0.0.0.0:4010/?folder=/ide.simplism.cloud

### With GitPod
> - Otherwise, you can [🍊 Open it with Gitpod](https://gitpod.io/#https://github.com/bots-garden/simplism-ide)
>   - Open `simplism-ide.code-workspace`
>   - Click on <kbd>Open Workspace</kbd>

## How to use it? (Write your first plug-in)

To write a Simplism plug-in have a look to the Simplism documentation:
- [Create and serve an Extism (wasm) plug-in](https://github.com/bots-garden/simplism/blob/main/docs/create-and-serve-wasm-plug-in.md)
- [Create a JSON service with an Extism plug-in](https://github.com/bots-garden/simplism/blob/main/docs/create-json-service.md)
- [Start an Simplism service from a configuration file](https://github.com/bots-garden/simplism/blob/main/docs/start-an-extism-service-with-config-file.md)
- [Start all the Slimplism services from a config file with the Flock mode](https://github.com/bots-garden/simplism/blob/main/docs/use-the-flock-mode.md)

## How to

### Add a TLS certificate

- First, copy the certificate and the key to `./certs`, 
- Then, change the permissions of the 2 files: `chmod 777 ide.simplism.cloud.*` (change the name with your domain)
- Create a directory of the `simplism-wizard` user:  `mkdir /home/simplism-wizard/certs`
- Copy the certificate and the key to the `certs` directory: `cp certs/* /home/simplism-wizard/certs`
- Create and copy a `config.yaml` file to `home/simplism-wizard/.config/code-server`:
```bash
cat > /home/simplism-wizard/.config/code-server/config.yaml <<- EOM
bind-addr: 0.0.0.0:4010
cert: certs/ide.simplism.cloud.crt
cert-key: certs/ide.simplism.cloud.key
EOM
```
> change the name with your domain

Then, update your `hosts` file:
```text
0.0.0.0 ide.simplism.cloud
```
Then, stop the services: `docker compose stop` and restart: `docker compose up`

Now you can reach the Web IDE with:
- https://ide.simplism.cloud:4010/?folder=/ide.simplism.cloud

👋 if you use `docker compose down` you will loose the configuration.
