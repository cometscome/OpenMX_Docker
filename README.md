# What is this?
This is Dockerfile for installing OpenMX with Intel OneAPI.

To build, just do

```bash
docker build --shm-size=2gb -t openmx .   
```

After building it, just do

```bash
docker run --shm-size=2gb --name oneopenmx -it openmx /bin/bash
```
