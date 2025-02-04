FROM ubuntu:24.10
ENV TZ=Europe/Paris DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y sudo
RUN useradd -ms /bin/bash pips
RUN usermod -aG sudo pips
RUN echo "pips:pips" | chpasswd
RUN echo "pips ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/pips
RUN chmod 044 /etc/sudoers.d/pips
USER pips
WORKDIR /home/pips
CMD ["/bin/bash"]
RUN sudo apt-get install -y \
  bash-completion \
  ca-certificates \
  wget \
  subversion \
  make \
  gcc \
  sed \
  perl \
  cproto \
  flex \
  bison \
  universal-ctags \
  libreadline-dev \
  libncurses-dev
RUN sudo apt-get install -y python-is-python3
RUN wget -O setup_pips.sh https://scm.cri.ensmp.fr/svn/nlpmake/trunk/makes/setup_pips.sh
RUN chmod +x setup_pips.sh
RUN bash setup_pips.sh MYPIPS pips
