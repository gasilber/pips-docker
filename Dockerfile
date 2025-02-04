FROM arm64v8/ubuntu:24.04
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
  git \
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
# Get and build Polylib
RUN git clone https://github.com/vincentloechner/polylib.git
RUN mkdir /home/pips/extern
WORKDIR /home/pips/polylib
RUN sudo apt install -y autoconf autoconf-archive gnu-standards autoconf-doc libtool gettext
RUN ./autogen.sh
RUN ./configure --prefix=/home/pips/extern
RUN make
RUN make install
ENV PIPS_ARCH=LINUX_aarch64_LL
RUN mkdir -p /home/pips/extern/lib/$PIPS_ARCH
WORKDIR /home/pips/extern/lib/$PIPS_ARCH
RUN ln -s ../libpolylib*64.a libpolylib.a
RUN ln -s ../libpolylib*64.so libpolylib.so
RUN ln -s ../libpolylib*64.so libpolylib64.so
RUN for so in ../libpolylib*.so.* ; do ln -s $so; done
# Build PIPS
WORKDIR /home/pips
RUN git clone https://github.com/criminesparis/pips.git
WORKDIR /home/pips/pips
RUN ln -s ../extern extern
RUN make -j 1 -C /home/pips/pips/newgen clean compile
RUN make -j 1 -C /home/pips/pips/linear clean compile
ENV PATH=/home/pips/pips/newgen/bin:/home/pips/pips/newgen/bin/$PIPS_ARCH:$PATH
RUN make -j 1 -C /home/pips/pips/pips clean compile
