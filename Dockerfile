FROM debian:latest

MAINTAINER DrSnowbird "DrSnowbird@openkbs.org"

ENV DEBIAN_FRONTEND noninteractive

############################################
#### ---- CA-Certifcates variable: ---- ####
############################################
ENV REQUESTS_CA_BUNDLE=${REQUESTS_CA_BUNDLE:-/etc/ssl/certs/ca-certificates.crt}

##################################
#### ---- Tools: setup   ---- ####
##################################
ENV LANG C.UTF-8
ARG LIB_DEV_LIST="apt-utils"
ARG LIB_BASIC_LIST="curl wget unzip ca-certificates"
ARG LIB_COMMON_LIST="sudo bzip2 git xz-utils unzip vim net-tools"
ARG LIB_TOOL_LIST="graphviz"

RUN set -eux; \
    apt-get update -y && \
    apt-get install -y --no-install-recommends ${LIB_DEV_LIST}  ${LIB_BASIC_LIST}  ${LIB_COMMON_LIST} ${LIB_TOOL_LIST} && \
    apt-get clean -y && apt-get autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf && \
    echo "Set disable_coredump false" | tee -a /etc/sudo.conf 
    
##############################################
#### ---- Installation Directories   ---- ####
##############################################
ENV INSTALL_DIR=${INSTALL_DIR:-/usr}
ENV SCRIPT_DIR=${SCRIPT_DIR:-$INSTALL_DIR/scripts}

############################################
##### ---- System: certificates : ---- #####
##### ---- Corporate Proxy      : ---- #####
############################################
COPY ./scripts ${SCRIPT_DIR}
COPY certificates /certificates
RUN ${SCRIPT_DIR}/setup_system_certificates.sh
RUN ${SCRIPT_DIR}/setup_system_proxy.sh

###################################
#### ---- user: developer ---- ####
###################################
ENV USER_ID=${USER_ID:-1000}
ENV GROUP_ID=${GROUP_ID:-1000}

ENV USER=${USER:-developer}
ENV HOME=/home/${USER}

ENV LANG C.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends sudo curl vim git ack wget unzip ca-certificates && \
    useradd -ms /bin/bash ${USER} && \
    export uid=${USER_ID} gid=${GROUP_ID} && \
    mkdir -p /home/${USER} && \
    mkdir -p /home/${USER}/workspace && \
    mkdir -p /etc/sudoers.d && \
    echo "${USER}:x:${USER_ID}:${GROUP_ID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \
    echo "${USER}:x:${USER_ID}:" >> /etc/group && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER} && \
    chown -R ${USER}:${USER} /home/${USER} && \
    apt-get autoremove; \
    rm -rf /var/lib/apt/lists/* && \
    echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

###################################
#### ---- Setup: conda3   ---- ####
###################################
RUN apt-get -qq update && apt-get -qq -y install curl bzip2 \
    && curl -k -sSL https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh \
    && bash /tmp/miniconda.sh -bfp /usr/local \
    && rm -rf /tmp/miniconda.sh \
    && conda install -y python=3 \
    && conda update conda \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
    && conda clean --all --yes \
    && chown $USER:$USER $HOME/.conda \
    && echo "export PATH=\$PATH:/opt/conda/bin" >> $HOME/.bashrc

RUN conda init bash

ENV PATH=$PATH:/opt/conda/bin
    
########################################
#### ---- Set up NVIDIA-Docker ---- ####
########################################
## ref: https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(Native-GPU-Support)#usage
## set both NVIDIA_VISIBLE_DEVICES and NVIDIA_VISIBLE_DEVICES with GPU-IDs to control the GPUs available inside the container
ENV TOKENIZERS_PARALLELISM=${TOKENIZERS_PARALLELISM:-true}
ENV NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
#ENV CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES:-0,1,2,3,4,5,6,7}
ENV NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:-compute,video,utility}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-/usr/local/cudnn/lib64:/usr/local/cuda/lib64:\${LD_LIBRARY_PATH}}

############################### 
#### ---- Entrypoint:     ----#
###############################
#### ---- App: (ENV)  ---- ####
###############################
ENV APP_HOME=${APP_HOME:-$HOME/app}
ENV APP_MAIN=${APP_MAIN:-setup.sh}

#########################################
##### ---- Docker Entrypoint : ---- #####
#########################################
COPY --chown=${USER}:${USER} docker-entrypoint.sh /
COPY --chown=${USER}:${USER} ${APP_MAIN} ${APP_HOME}/setup.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

##################################
#### ---- start user env ---- ####
##################################
USER ${USER}
WORKDIR "$HOME"

CMD ["bash"]

