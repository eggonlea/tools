set -x
dd status=progress if=/dev/sda of=start.bak count=15500000
dd status=progress if=/dev/sda of=end.bak count=101651456 skip=976574630
