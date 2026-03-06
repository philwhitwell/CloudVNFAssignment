sudo apt update

sudo apt install -y \
    git \
    make \
    gcc \
    g++ \
    libsctp-dev \
    lksctp-tools \
    iproute2 \
    iputils-ping

sudo apt install cmake

cmake --version


git clone https://github.com/aligungr/UERANSIM
cd UERANSIM

make

./build/nr-ue --help

#check the config files
then start the gNodeB
sudo ./build/nr-gnb -c config/open5gs-gnb.yaml