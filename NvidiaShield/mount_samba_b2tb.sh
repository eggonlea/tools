# sudo apt install cifs-utils
sudo mount -t cifs -o username=eggonlea,password=tape-snick-browse,uid=$(id -u),gid=$(id -g) //192.168.1.3/b2tb $PWD/b_mnt
