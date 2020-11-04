FROM gitpod/workspace-full

USER root

RUN apt-get install -yq hugo 

USER gitpod