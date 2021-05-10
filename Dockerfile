ARG osver=7
FROM centos:${osver}

ARG osver
ARG user=${user:-crdb}
ARG gover=1.15.12
ARG cmakebigver=3.11
ARG cmakever=3.11.2
ARG tmuxver=3.1b

RUN yum install wget -y && \
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-${osver}.repo && \
    yum makecache && \
    yum install -y sudo net-tools git which dstat vim openssh-server gcc gcc-c++ make autoconf bison ncurses-devel ncurses-static && \
    yum clean all

# Generate ssh host keys
RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa && \
    ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa && \
    ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

# change timezone to Asia/Shanghai
RUN mv /etc/localtime /etc/localtime.bak && \
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Add user
RUN useradd -m -U -u 1000 ${user} && \
    echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo "alias vi=vim" >> /home/${user}/.bashrc

USER ${user}

# Generate user ssh keys
RUN ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa && \
    cp -a ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys && \
    echo "NoHostAuthenticationForLocalhost=yes" >>~/.ssh/config

WORKDIR /tmp
#COPY --chown=${user}:${user} software/* ./

USER root

# install go and  Set go GOPROXY env
RUN wget https://dl.google.com/go/go${gover}.linux-amd64.tar.gz && \
    tar -C /usr/local/ -zxvf go${gover}.linux-amd64.tar.gz && \
    echo -e "export GOROOT=/usr/local/go\nexport PATH=$PATH:$GOROOT/bin" >> /etc/profile && \
    echo "export GOPATH=/home/${user}/cockroachdb" >> /home/${user}/.bashrc && \
    cp /usr/local/go/bin/* /usr/bin && \
    rm -rf go${gover}.linux-amd64.tar.gz && \
    go env -w GOPROXY=https://goproxy.cn,direct

# install cmake
RUN wget https://cmake.org/files/v${cmakebigver}/cmake-${cmakever}-Linux-x86_64.tar.gz && \
    tar -C /usr/local/ -zxvf cmake-${cmakever}-Linux-x86_64.tar.gz && \
    ln -s /usr/local/cmake-${cmakever}-Linux-x86_64/bin/* /usr/bin/ && \
    rm -rf cmake-${cmakever}-Linux-x86_64.tar.gz

# node.js
#RUN curl --silent --location https://rpm.nodesource.com/setup_12.x | bash -
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - && \
    yum install -y nodejs && yum clean all

# Yarn
RUN curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    yum -y install yarn && yum clean all

# PRIVATE

# 1 Install tmux
# 1.1 Install libevent 2.1.8
RUN wget https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz && \
    tar -xzvf libevent-2.1.8-stable.tar.gz && \
    cd libevent-2.1.8-stable && \
    ./configure && \
    make -j8 && \
    make install && \
    cd ../ && \
    rm -rf libevent-2.1.8-stable.tar.gz libevent-2.1.8-stable/

# 1.2 Install ncurses and automake
RUN yum install ncurses automake -y && \
    yum clean all

# 1.3 Install tmux
#RUN git clone https://github.com/tmux/tmux.git
RUN wget https://github.com/tmux/tmux/releases/download/${tmuxver}/tmux-${tmuxver}.tar.gz && \
    tar xzvf tmux-${tmuxver}.tar.gz && \
    cd tmux-${tmuxver} && \
    ./configure && \
    make -j8 && \
    make install && \
    cp tmux /usr/bin/tmux -f && \
    cp tmux /usr/local/bin/tmux -f && \
    cp /usr/local/lib/libevent-2.1.so.6 /lib64/libevent-2.1.so.6 && \
    cd .. && \
    rm -rf tmux-${tmuxver}.tar.gz tmux-${tmuxver}/

# Tmux Resurrect
RUN mkdir ~/.tmux && cd ~/.tmux && git clone https://github.com/tmux-plugins/tmux-resurrect.git && \
    echo "run-shell ~/.tmux/tmux-resurrect/resurrect.tmux" >> ~/.tmux.conf
# PRIVATE

WORKDIR /home/${user}
USER ${user}

ENTRYPOINT sudo /usr/sbin/sshd && /bin/bash
