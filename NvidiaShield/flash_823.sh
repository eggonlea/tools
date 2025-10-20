set -x
dd status=progress if=start.823 of=/dev/sda bs=4M
dd status=progress if=end.823 of=/dev/sda seek=976574630
