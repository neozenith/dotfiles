#! /bin/bash
# https://github.com/nodesource/distributions#installation-instructions
__WDIR=$(pwd)

sudo apt-get update && sudo apt-get upgrade -y
sudo apt install -y ca-certificates curl gnupg
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/nodesource.gpg

NODE_MAJOR=21
echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

sudo apt-get update
sudo apt-get install -y nodejs

which node
node --version
which npm
npm --version

cd $__WDIR
