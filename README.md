# Conda3 + Non-root + Docker Container

# Build
There are three variations to build, namely:
1. (default) Conda base only
```
        make build
```
2. Conda + Jupyter
```
        make build-jupyter
```
3. Conda + Jupyter + Pytorch (w/cuda 11.x) + Tensorflow (w/GPU v2.x)
```
        make build-pytorch
```

# (optional) Configuration
New extension to allow users to enter "Volume mapping" and "Port mapping" entries together with "docker.env" file with "#" syntax to avoid docker-compose pick up the entries -- "Rider" configuration!
Here is the example syntax:
```
## Rider configuration for run.sh ####
# - Use "#VOLUMES" and "#PORTS" to indicate that the variables for run.sh"
# - To ignore line, use "##" (double) in the beginning, e.g. "##VOLUMES" and "##PORTS"
# - To indicate that the variables for run.sh", use only one "#",  e.g. "#VOLUMES" and "#PORTS"
#VOLUMES_LIST="data workspace"
##PORTS_LIST="18888:8888"
```
# Run
- To run the simple example build image; it will pop up X11 to display Firefox docker-based browser.
Note that the script "run.sh" is designed to generic for every project with assumption that it use the "current git directory name" to figure out the image name you may want to use.
```
./run.sh
```
Or,
```
docker-compose up
```
Or,
```
make up
```
# Utility Scripts
Scripts under ./bin have several useful bash scripts to jump start what you need.
1. dockerCE-install.sh: Install docker CE with latest version available.
2. portainer_resume.sh: Launch portainer to manage all you desktop Docker containers.
3. container-launcher.sh: Launch specific container using "pattern expression".

# Corporate Proxy Root and Intemediate Certificates setup for System and Web Browsers (FireFox, Chrome, etc)
1. Save your corporate's Certificates in the currnet GIT directory, `./certificates`
2. During Docker run command, 
```
   -v `pwd`/certificates:/certificates ... (the rest parameters)
```
If you want to map to different directory for certificates, e.g., /home/developer/certificates, then
```
   -v `pwd`/certificates:/home/developer/certificates -e SOURCE_CERTIFICATES_DIR=/home/developer/certificates ... (the rest parameters)
```
3. And, inside the Docker startup script to invoke the `~/scripts/setup_system_certificates.sh`. Note that the script assumes the certficates are in `/certificates` directory.
4. The script `~/scripts/setup_system_certificates.sh` will automatic copy to target directory and setup certificates for both System commands (wget, curl, etc) to use and Web Browsers'.

# References & Resources
* [Docker ARG and ENV Guide](https://vsupalov.com/docker-arg-env-variable-guide/)
* [Docker SECCOMP](https://en.wikipedia.org/wiki/Seccomp)
* [Docker Proxy setup](https://docs.docker.com/network/proxy/)

# Docker Finer-grained Access Control 
Docker is a software that allows to run applications inside of isolated containers. Docker can associate a seccomp profile with the container using the **--security-opt** parameter. Using OPA, you can easily have finer-grained access control.
* [OpenPolicyAgent OPA](https://www.openpolicyagent.org/docs/docker-authorization.html)

# Setup Dockerfile Build behind Corporate Proxies
* [Docker Proxy](https://docs.docker.com/engine/reference/commandline/cli/ https://docs.docker.com/network/proxy/)

# Proxy & Certificate Setup
* [Setup System and Browsers Root Certificate](https://thomas-leister.de/en/how-to-import-ca-root-certificate/)

For corporate with proxies, to build the images, you need to setup proxy. The better way to setup proxy for docker build and daemon is to use configuration file and there is no need to change the Dockerfile to contain your proxies setup.

With new feature in docker option --config, you needn't set Proxy in Dockerfile any more.

--config string : Location of client config files (default `~/.docker/config.json`)
or environment variable DOCKER_CONFIG

`DOCKER_CONFIG` : The location of your client configuration files.
```
(the following is default docker config file)
export DOCKER_CONFIG=~/.docker/config.json
```
It is recommended to set proxy with httpProxy, httpsProxy and ftpProxy in `~/.docker/config.json` unless it is not feasible to set up this config file, e.g., in Openshift, or Kubernetes environments. You need to adjust the DNS proxy hostname according to your specifics of your corporate proxy.
```
{
    "proxies":
    {
        "default":
        {
            "httpProxy": "http://proxy.openkbs.org:80",
            "httpsProxy": "http://proxy.openkbs.org:80",
            "ftpProxy": "http://proxy.openkbs.org:80",
            "noProxy": "127.0.0.1,localhost,.openkbs.org"
        }
    }
}
```
Adjust proxy IP and port if needed and save to `~/.docker/config.json`
