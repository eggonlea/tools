set -x
if ! mountpoint -q /mnt/sshfs; then
sshfs asrserver:/home/li /mnt/sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3,idmap=user,allow_other
fi
