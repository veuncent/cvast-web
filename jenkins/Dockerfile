FROM jenkins

USER root

RUN apt-get update -y

# Give jenkins sudo rights
RUN apt-get install -y sudo \
RUN rm -rf /var/lib/apt/lists/*
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN apt-get install -y lxc

RUN curl -O https://bootstrap.pypa.io/get-pip.py
RUN sudo python get-pip.py
RUN sudo pip install awscli

USER jenkins

ENV INSTALL_DIR=/install

# Entrypoint to setup volume mounts
COPY jenkins_entrypoint.sh ${INSTALL_DIR}/jenkins_entrypoint.sh
RUN chmod -R 700 ${INSTALL_DIR}

# For later, if we want to install plugins
# USER jenkins
# COPY plugins.txt /usr/share/jenkins/plugins.txt
# RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt


ENTRYPOINT ${INSTALL_DIR}/jenkins_entrypoint.sh