
# XBackBone Docker Image

This repository packages [XBackBone](https://github.com/SergiX44/XBackBone) on top of [webdevops/php-nginx](https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html) and publishes the image to GitHub Container Registry.

## Image publishing

GitHub Actions builds and publishes `linux/amd64` images to `ghcr.io/davidjameshowell/xbackbone-docker-x64` on pushes to `main`, tags, and manual workflow runs.

To pull the latest image:

```console
docker pull ghcr.io/davidjameshowell/xbackbone-docker-x64:latest
```

## Run the container

```console
docker run -p 80:80 \
    -e APP_NAME=XBackBone \
    -e URL=http://127.0.0.1 \
    --name xbb \
    ghcr.io/davidjameshowell/xbackbone-docker-x64:latest
```

Container logs are available with `docker logs xbb`.

## Build locally

The helper script builds the image from `docker/xbackbone/Dockerfile` and runs the same container test suite used by CI.

```bash
bash scripts/build-image.sh
```

Useful overrides:

- `IMAGE_TAG=xbackbone-docker:dev bash scripts/build-image.sh`
- `XBACKBONE_VERSION=3.8.1 bash scripts/build-image.sh`
- `RUN_TESTS=false bash scripts/build-image.sh`

## Docker Compose

The repository includes a Compose stack for the application and MariaDB:

```bash
docker compose up -d
```

To reuse an already-built image instead of rebuilding inside Compose:

```bash
XBACKBONE_IMAGE=xbackbone-docker:local docker compose up -d --no-build
```

## Configuration

### Environment variables

- `APP_NAME`: application name shown by XBackBone. Default: `XBackBone`
- `URL`: public application URL. Default: `http://127.0.0.1`
- `SKIP_CONFIGURE`: disables automatic config mutation when you provide your own `config.php`
- `DB_TYPE=mysql`: switches database configuration from SQLite to MariaDB/MySQL
- `LDAP_ENABLED`: enables LDAP settings injection

### Build arguments

- `XBACKBONE_VERSION`: XBackBone release tag to download during image build

Build a specific release manually:

```bash
docker build --build-arg XBACKBONE_VERSION=3.8.1 -t xbackbone-docker:3.8.1 ./docker/xbackbone
```

### Persistent data

The image exposes these mount points:

- `/app/storage`
- `/app/resources/database`
- `/app/logs`
- `/app/config`

Bind-mounted host directories should be owned by UID/GID `1000`.

### Repository layout

- `docker/xbackbone`: Dockerfile and image-specific config
- `scripts`: local build and integration entrypoints
- `tests/integration`: shell-based runtime checks
- `env/compose.env`: tracked Compose environment file

### PHP tuning

You can set PHP options with environment variables such as `php.memory_limit=256M`.
See the [webdevops PHP variable reference](https://dockerfile.readthedocs.io/en/latest/content/DockerImages/dockerfiles/php-nginx.html#php-ini-variables) for the full list.

## LDAP authentication

Supported LDAP environment variables:

- `LDAP_ENABLED`
- `LDAP_HOST`
- `LDAP_PORT`
- `LDAP_BASE_DOMAIN`
- `LDAP_USER_DOMAIN`
- `LDAP_RDN_ATTRIBUTE`

See the [XBackBone configuration docs](https://xbackbone.app/configuration.html#ldap-authentication) for details.

## Upgrade note

When upgrading from versions older than `3.1.4`, run:

```bash
echo '-' > YOUR_STORAGE_VOLUME/storage/.installed
```

## License

See [LICENSE](LICENSE).
