apt-get install -y parallel sox libsox-fmt-mp3

#tar --warning=no-unknown-keyword -xf mp3.tar.gz --totals

set +e
find ./mp3 -name '*.mp3' | parallel --bar sox -G {} --compression 0.0 --no-dither -e signed -L -c 1 -b 16 -r 16k -t wav ./wav/{/.}.wav
set -e
