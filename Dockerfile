ARG osver=7
FROM centos:${osver}
ARG user=${user:-drdb}

# Cleanup yum
RUN yum clean all

RUN yum install -y sudo net-tools wget git which dstat openssh-server gcc gcc-c++ make autoconf bison ncurses-devel ncurses-static

# Generate ssh host keys
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

# Add user
RUN useradd -m -U -u 1000 ${user}
RUN echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${user}

# Generate user ssh keys
RUN ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa
RUN cp -a ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
RUN echo "NoHostAuthenticationForLocalhost=yes" >>~/.ssh/config

# copy cmake-3.11.2.tar.gz 
# copy go1.11.2.linux-amd64.tar.gz
RUN mkdir -p /home/${user}/software
WORKDIR /home/${user}/software
#COPY --chown=${user}:${user} software/* ./
RUN wget https://dl.google.com/go/go1.11.2.linux-amd64.tar.gz
RUN wget https://cmake.org/files/v3.11/cmake-3.11.2.tar.gz

USER root

# install go
RUN tar -C /usr/local -zxvf go1.11.2.linux-amd64.tar.gz
RUN echo "export GOROOT=/usr/local/go" >> /etc/profile
RUN echo "export PATH=$PATH:$GOROOT/bin" >> /etc/profile

RUN cp /usr/local/go/bin/go /usr/bin
RUN cp /usr/local/go/bin/gofmt /usr/bin
RUN cp /usr/local/go/bin/godoc /usr/bin

# install cmake
RUN tar -zxvf cmake-3.11.2.tar.gz
WORKDIR /home/${user}/software/cmake-3.11.2
RUN ./bootstrap --prefix=/usr
RUN gmake
RUN sudo gmake install

# access github 
RUN sudo echo "192.30.253.112 github.com" >> /etc/hosts

# node.js
RUN curl --silent --location https://rpm.nodesource.com/setup_10.x | bash -
RUN yum install -y nodejs

# Yarn
RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
RUN yum -y install yarn

# PRIVATE
WORKDIR /home/${user}/software

# 1 Install tmux
# 1.1 Install libevent 2.1.8
RUN wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
RUN tar xzvf libevent-2.1.8-stable.tar.gz
RUN cd libevent-2.1.8-stable && ./configure && make -j8 && make install

# 1.2 Install ncurses and automake
RUN yum install ncurses automake -y

# 1.3 Install tmux
RUN git clone https://github.com/tmux/tmux.git
RUN cd tmux &&  ./autogen.sh && ./configure && make -j8 && make install
RUN cd tmux && cp tmux /usr/bin/tmux -f && cp tmux /usr/local/bin/tmux -f && cp /usr/local/lib/libevent-2.1.so.6 /lib64/libevent-2.1.so.6

# PRIVATE

# Cleanup yum
RUN yum clean all

WORKDIR /home/${user}
USER ${user}
ENTRYPOINT sudo /usr/sbin/sshd && /bin/bash
