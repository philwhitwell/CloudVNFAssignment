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
#then start the gNodeB
sudo ./build/nr-gnb -c config/open5gs-gnb.yaml

#in separate window
sudo ./build/nr-ue -c config/open5gs-ue.yaml

#[2026-03-07 12:02:57.146] [app] [info] Connection setup for PDU session[1] is successful, TUN interface[uesimtun0, 10.45.0.2] is up.