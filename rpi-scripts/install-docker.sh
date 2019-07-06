# https://medium.freecodecamp.org/the-easy-way-to-set-up-docker-on-a-raspberry-pi-7d24ced073ef
curl -fsSL get.docker.com -o get-docker.sh 
sh get-docker.sh
sudo usermod -aG docker `whoami`
systemctl start docker

