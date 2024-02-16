# Amazon Linux 2 Docker Image with systemd

This repository includes a `Dockerfile` to build an image for using `systemd` on Amazon Linux 2 container. It also includes `docker-compose.yaml` which is a sample for starting the image.

## Before Using This Package

You are reading this `README.md` probably because you are having some sort of problem and are trying to somehow start `systemd` on a Docker container just like you would on a regular Linux host.
The `Dockerfile` and `docker-compose.yaml` file in this project may be able to answer that question. However, please note that using `systemd` on Docker container is not common approach.

Why is it not a common approach? There's a great answer on [Stack overflow](https://stackoverflow.com/questions/51979553/is-it-recommended-to-run-systemd-inside-docker-container):

> [Systemd](https://www.freedesktop.org/wiki/Software/systemd/) mounts filesystems, controls several kernel parameters, has its own internal system for capturing process output, configures system swap space, configures huge pages and POSIX message queues, starts an inter-process message bus, starts per-terminal login prompts, and manages a swath of system services. Many of these are things Docker does for you; others are system-level controls that Docker by default prevents (for good reason).
>
> Usually you want a container to do one thing, which occasionally requires multiple coordinating processes, but you usually don't want it to do any of the things systemd does beyond provide the process manager. Since systemd changes so many host-level parameters you often need to run it as --privileged which breaks the Docker isolation, which is usually a bad idea.
> 
> As you say in the question, running one "piece" per container is usually considered best. If you can't do this then a light-weight process manager like supervisord that does the very minimum an init process is required to is a better match, both for the Docker and Unix philosophies.

However, there may be some cases where you want to use `systemd` on Docker container, even if it is not the most efficient way. I found a way to use `systemd` on a Docker container after facing such a situation, so I decided to leave it here.

## How to Use

In the following sections, we use `docker-compose` command to build an image and start a container. If you want to start without using the `docker-compose`` command, go to the next chapter.

### Create and Start Containers

You can build, create, start, and attach to containers for a service by following command:

```
$ docker-compose up -d
```

After above command complete successfully, run following command to list containers:

```
$ docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED              STATUS              PORTS                    NAMES
42f334aad15f   amazon-linux-2-systemd:latest   "/bin/sh -c /usr/lib…"   About a minute ago   Up About a minute   0.0.0.0:8080->80/tcp     amazon-linux-2-systemd
```

If you see your container is listed and running, login to your container by following command: 

```
$ docker exec -it amazon-linux-2-systemd bash
```

Run `systemctl` command to see if `systemd` is running on the container.

```
# systemctl
UNIT                           LOAD   ACTIVE     SUB       DESCRIPTION
dev-vda1.device                loaded activating tentative /dev/vda1
-.mount                        loaded active     mounted   /
dev-mqueue.mount               loaded active     mounted   POSIX Message Queue File System
...
...
```

Run following command to install HTTP server for example. 

```
# sudo yum -y install httpd
```

Start httpd server using `systemctl`.

```
# systemctl start httpd
# systemctl status httpd
```

If everything is working expected, you will be able to open an Apache Test Page using your Web Browser on localhost by accessing to following link:

```
127.0.0.1:8080
```

### Stop

You can stop and remove containers, networks and volumes created by `up`. by following command. If you want to remove images used by services as well, add `--rmi all` option.

```
$ docker-compose down
```
or
```
$ docker-compose down --rmi all
```

## Build Image

If you want to build an image without using the `docker-compose` command, use the following command.

```
$ docker build -t amazon-linux-2-systemd:latest .
```

## Run Docker Container

If you want to start a container without using `docker-compose`, use the following command. As a prerequisite, you need to build the image using the above command.

```
$ docker run -d --name amazon-linux-2-systemd --privileged -p 8080:80 --tmpfs /run,/run/lock --tty -v /tmp/systemd:/sys/fs/cgroup:rw amazon-linux-2-systemd:latest
```

## References
- https://hub.docker.com/r/centos/systemd/dockerfile/
- https://github.com/robertdebock/docker-amazonlinux-systemd