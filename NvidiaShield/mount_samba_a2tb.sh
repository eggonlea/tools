# sudo apt install cifs-utils
sudo mount -t cifs -o username=eggonlea,password=tape-snick-browse,uid=$(id -u),gid=$(id -g) //192.168.1.3/a2tb $PWD/a_mnt
