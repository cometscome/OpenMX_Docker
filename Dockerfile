FROM --platform=linux/x86_64 ubuntu:latest

RUN apt-get update
RUN apt-get install -y sudo

RUN useradd --uid 1001 --create-home --shell /bin/bash -G sudo,root openmxperson
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER openmxperson

WORKDIR /home/openmxperson
ADD . /home/openmxperson

RUN sudo apt update -y; sudo apt install -y wget gnupg \
 && cd /tmp \
&& sudo wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
&& sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
&& sudo rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
&& echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list \
&& sudo apt update -y \
&& sudo apt install intel-oneapi-compiler-fortran intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic \
    intel-oneapi-mkl intel-oneapi-mpi intel-oneapi-mpi-devel -y \
&& echo "source /opt/intel/oneapi/setvars.sh" | cat >> ~/.bashrc  

RUN sudo apt install emacs gcc make patch -y \
    && sudo apt install libfftw3-3 libfftw3-dev libfftw3-doc -y \
    && sudo ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so

RUN wget http://t-ozaki.issp.u-tokyo.ac.jp/openmx3.9.tar.gz \
    && wget http://www.openmx-square.org/bugfixed/20Feb11/patch3.9.2.tar.gz \
    && . /opt/intel/oneapi/setvars.sh \
    && tar -xvf openmx3.9.tar.gz \
    && cp ./patch3.9.2.tar.gz openmx3.9/source/ \
    && cd openmx3.9/source \
    && tar zxvf patch3.9.2.tar.gz \
    && mv kpoint.in ../work/ \
    && cp /home/openmxperson/makefile.patch . \
    && patch -u makefile < makefile.patch \
    && make all \
    && make install

ENV PATH=/home/openmxperson/openmx3.9/work/:$PATH

CMD ["bash"]