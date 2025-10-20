set -x
dd status=progress if=start.bin of=/dev/sda bs=4M
dd status=progress if=end_976574630.bin of=/dev/sda seek=976574630
