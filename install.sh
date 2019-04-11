sudo apt-get update
sudo apt-get -y install git libgmpxx4ldbl libbdd0c2

raco pkg install --auto

cd ..

wget http://de.archive.ubuntu.com/ubuntu/pool/main/r/readline/libreadline7_7.0-3_amd64.deb
sudo dpkg -i libreadline7_7.0-3_amd64.deb 
rm libreadline7_7.0-3_amd64.deb

wget http://blockchain.unica.it/maude/maude.tar.gz 
tar -xf maude.tar.gz

git clone https://github.com/bitml-lang/bitml-maude.git || true

sudo rm /etc/profile.d/bitml.sh
sudo sh -c "echo \"export MAUDE_PATH=`pwd`/maude\" >> /etc/profile.d/bitml.sh"
sudo sh -c "echo \"export MAUDE_MC_PATH=`pwd`/maude\" >> /etc/profile.d/bitml.sh"
sudo sh -c "echo \"export BITML_MAUDE_PATH=`pwd`/bitml-maude\" >> /etc/profile.d/bitml.sh"
sudo chmod +x /etc/profile.d/bitml.sh
/etc/profile.d/bitml.sh

