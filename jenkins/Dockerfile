FROM cvast-build.eastus.cloudapp.azure.com:5000/jenkins:2

USER root

RUN apt-get update -y

RUN apt-get install -y apt-transport-https ca-certificates
# Add the Docker GPG key.
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

RUN echo "deb https://apt.dockerproject.org/repo ubuntu-wily main" > /etc/apt/sources.list.d/docker.list

RUN apt-get update -y

# Verify that APT is pulling from the right repository.
#RUN apt-cache policy docker-engine

# The linux-image-extra package allows you use the aufs storage driver.
# RUN apt-get purge -y grub grub-pc grub-common
# RUN apt-get install -y grub-common grub-pc
# RUN update-grub -y
# RUN apt-get install -y linux-image-extra-$(uname -r)

#RUN apt-get install -y libdevmapper1.02.1

# Install Docker
RUN apt-get install -y docker-engine

USER jenkins

CMD service docker start
