set -x
dd status=progress if=start.800 of=/dev/sda bs=4M
dd status=progress if=end.800 of=/dev/sda seek=976574630
