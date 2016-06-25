FROM jenkins

USER root

RUN apt-get update -y

# Give jenkins sudo rights
RUN apt-get install -y sudo \
RUN rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN apt-get install -y lxc

USER jenkins

# For later, if we want to install plugins
# USER jenkins
# COPY plugins.txt /usr/share/jenkins/plugins.txt
# RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt
