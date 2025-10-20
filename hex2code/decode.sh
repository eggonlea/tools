./hex2bin.py < hex > bin
arm-linux-androideabi-objdump -b binary -m arm -M force-thumb2 -D bin
#arm-linux-androideabi-objdump -b binary -m arm -D bin
