# WSC Dockerized

#### WSC (WoltLab Suite Core) in Docker

## Prerequisites

##### Linux
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [BuildKit](https://docs.docker.com/build/buildkit/) for the PHP-FPM build targets

##### Windows
- [WSL 2](https://docs.microsoft.com/windows/wsl/install)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)

## What's inside?

Every version is shipped with the same basic components:

- nginx 1.27.3 + headers-more module
- PHP
  + exif
  + intl
  + gd (incl. WebP support)
  + imagick (using ImageMagick 7)
  + pdo_mysql
  + redis (WSC < 6.3)
  + opcache (without pre-configured JIT)
  + gmp
- MariaDB LTS
  + 1 GB InnoDB Buffer Pool Size
- Dragonfly (redis, WSC < 6.3)

Set `PHP_VERSION` in `.env` to a PHP series supported by your WoltLab Suite version.

| WoltLab Suite | Supported PHP series |
|---------------|----------------------|
| 6.3 | 8.4 (8.4.27 or later), 8.5 (8.5.12 or later) |
| 6.2 | 8.1 through 8.4 |
| 6.0 and 6.1 | 8.1 through 8.3 |
| 5.5 | 7.4 through 8.1 |
| 5.4 | 7.2 through 8.0 |
| 5.2 and 5.3 | 7.0 through 7.4 |
| 3.0 and 3.1 | 5.5 through 7.4 |

Every PHP-FPM build target requires a fix for CVE-2026-109618 and
CVE-2026-109619. PHP 8.2 through 8.5 use official images pinned by digest.
PHP 5.6 through 8.1 use signed DEB.SURY.ORG backports for `linux/amd64`,
`linux/arm64`, and `linux/arm/v7`. PHP 5.5 uses signed CloudLinux packages
starting at revision `5.5.38-183` and requires `linux/amd64`.
[PHP security advisory](https://www.php.net/archive/2026.php#2026-10-21-5),
[DEB.SURY.ORG package repository](https://packages.sury.org/php/),
[CloudLinux advisory](https://cloudlinux.zendesk.com/hc/en-us/articles/31194180517916)

| `PHP_VERSION` | Release selector |
|---------------|------------------|
| `5.5` | `5.5.38` |
| `5.6` | `5.6.40` |
| `7.0` | `7.0.33` |
| `7.1` | `7.1.33` |
| `7.2` | `7.2.34` |
| `7.3` | `7.3.33` |
| `7.4` | `7.4.33` |
| `8.0` | `8.0.30` |
| `8.1` | `8.1.34` |
| `8.2` | `8.2.35` |
| `8.3` | `8.3.36` |
| `8.4` (default) | `8.4.27` |
| `8.5` | `8.5.12` |

The two selectors in each row build the same PHP runtime. For a direct
Docker build, use `--target`, for example `--target php-8.5`. Legacy package
updates are checked by package revision because the PHP version banner can
stay the same after a security backport.

## Installation

The following instructions mainly refer to the installation via console. For Docker Desktop-specific instructions, please refer to the related [manual](https://docs.docker.com/desktop/dashboard/).

##### Download/Checkout

Execute the following code to download the whole project:

```bash
git clone https://github.com/SoftCreatR/wsc-dockerized
cd wsc-dockerized
```

##### Container setup

After checking out the desired WoltLab Suite Core version, it's time to set-up the container, but before proceeding, make sure to set-up the database credentials first. To do so, __copy__ the file `.env.example` to `.env`, and edit the file. The options are self-explanatory. This step is optional, but it is recommended to perform it, especially if you want to use a specific WSC, or PHP version.

To start the container setup, execute this command:

```bash
./compose.sh up
```

If you already have a container from an earlier checkout, update your
`PHP_VERSION` if needed and run `./compose.sh up -d --build php-fpm` to rebuild
and recreate the PHP-FPM container with its patched runtime.

Depending on the host machine, this process may take a few minutes (especially on Windows, using Docker Desktop)

##### WoltLab Suite Core installation

As soon as the container has been set-up successfully, you can install the WoltLab software itself. To do so, point your web browser to `http://hostname-or-ip` (e.g. `http://localhost`). You should now see something similar to this:

![image](https://user-images.githubusercontent.com/81188/172990934-0534007f-575a-44b7-8203-9c66434e5cca.png)

If this is the case: Congrats, you are nearly done. If not: Whoops. Something went wrong. Check your log files, and make sure, that you followed all steps until here. If nothing helps, [file an issue](https://github.com/SoftCreatR/wsc-dockerized/issues/new).

Click on the "Start installation" button to proceed.

Since this project is primarily aimed at developers, you probably want to set up the software in developer mode. In this case, call the `install.php` file with the parameter `dev=1`, for example `http://localhost/install.php?dev=1`.

During the installation, you might be asked for database information. It's important to know, that the database server is not reachable via `localhost`, or `127.0.0.1`, but `mysql`. It's also worth noting, that MySQL will be installed with a pre-created database, and pre-defined login information, if you didn't configure it during the container setup:

- Database name: `woltlab_suite`
- Database user: `woltlab_suite`
- Database password: `woltlab_suite`

##### Finish

You may wonder, if this was already everything, and the simple answer is:

![image](https://github.com/user-attachments/assets/1469c98b-be7b-4c6c-9b3d-10514570a462)


If no errors occurred during the installation process, everything is set-up, and you can enjoy using the WoltLab software 🎉

## FAQ

__Question:__ How can I use redis as caching method?

__Answer:__

1. Log in to the administration panel of your WoltLab Suite Core installation (e.g. `http://localhost/acp`)
2. Head over to Configuration -> General -> Cache
3. Check `Use Redis` under `Caching Method`
4. Paste `redis:6379` into the `Redis-Server` input field

This is only applicable to WSC versions below 6.3.

## Troubleshooting

__Problem:__ redis doesn't seem to work after setting it up, it always shows "Filesystem" as cache source.
__Solution:__ The given redis server ip is invalid. Make sure, not to use `localhost`, or `127.0.0.1`. The correct hostname is `redis`.

__Problem:__
> An error has occurred while trying to connect to your database:
> 
> Connecting to MySQL server 'localhost' failed
> 
> SQLSTATE[HY000] [2002] No such file or directory
> 

__Solution:__ The given MySQL hostname is incorrect. Make sure, not to use `localhost`, or `127.0.0.1`. The correct hostname is `mysql`.

__Problem:__
> An error has occurred while trying to connect to your database:
> 
> Connecting to MySQL server 'mysql' failed
> 
> SQLSTATE[HY000] [1045] Access denied for user '###'@'wsc_php-fpm_1.wsc_default' (using password: YES)

__Solution:__ The given username, and/or password, and/or database name is incorrect. If you did not set-up custom database information, the correct information is:

- Database name: `woltlab_suite`
- Database user: `woltlab_suite`
- Database password: `woltlab_suite`

## Contributing

If you have any ideas, just open an issue and describe what you would like to add/change.

If you'd like to contribute, please fork the repository and make changes as you'd like. Pull requests are warmly welcome.

## License 🌳

[ISC](LICENSE.md) © [1-2.dev](https://1-2.dev)

This package is Treeware. If you use it in production, then we ask that you [**buy the world a tree**](https://ecologi.com/softcreatr?r=61212ab3fc69b8eb8a2014f4) to thank us for our work. By contributing to the ecologi project, you’ll be creating employment for local families and restoring wildlife habitats.
