SHELL=/bin/sh
PATH=/home/li/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

date > /tmp/opengrok.log
echo "Start opengrok..." >> /tmp/opengrok.log

IGNORE_PATTERNS=" \
-i d:.git \
-i d:.idea \
-i d:.repo \
-i d:DATA \
-i d:dataset \
-i d:bak \
-i d:bin \
-i d:generated \
-i d:intermediates \
-i d:out \
-i d:outputs \
-i d:raw \
-i d:res-560dpi \
-i d:static_test_env \
-i d:test_data \
-i d:tmp \
-i d:versioner-dependencies \
-i f:.gitignore \
-i f:filelist \
-i f:tags \
-i *.3gp \
-i *.a \
-i *.aac \
-i *.aar \
-i *.acdb \
-i *.apk \
-i *.ARW \
-i *.arw \
-i *.bin \
-i *.bmp \
-i *.bz2 \
-i *.class \
-i *.data \
-i *.dat \
-i *.db \
-i *.dex \
-i *.dump \
-i *.dylib \
-i *.exe \
-i *.flac \
-i *.fw \
-i *.gif \
-i *.gz \
-i *.HEX \
-i *.hex \
-i *.ico \
-i *.ihex \
-i *.img \
-i *.jack \
-i *.jar \
-i *.jepg \
-i *.JPG \
-i *.jpg \
-i *.key \
-i *.lib \
-i *.m4a \
-i *.md5 \
-i *.mkv \
-i *.mp3 \
-i *.mp4 \
-i *.o \
-i *.odex \
-i *.ogg \
-i *.out \
-i *.pdb \
-i *.pdf \
-i *.pem \
-i *.png \
-i *.pyc \
-i *.RAF \
-i *.raf \
-i *.rar \
-i *.raw \
-i *.sha1 \
-i *.so \
-i *.spv \
-i *.svg \
-i *.swp \
-i *.tar \
-i *.test \
-i *.tmp \
-i *.vdex \
-i *.vp8 \
-i *.vp9 \
-i *.wav \
-i *.webm \
-i *.webp \
-i *.xz \
-i *.z \
-i *.zip \
-i *.zlib \
"

JAVA_OPTS="$JAVA_OPTS -Xms16g -Xmx16g -d64 -server" \
time java -jar /opt/opengrok/lib/opengrok.jar -m 256 -P --progress -S -v -c /home/li/bin/ctags -s /srv/vobs -d /opt/opengrok/data -W /opt/opengrok/etc/configuration.xml $IGNORE_PATTERNS

date >> /tmp/opengrok.log
echo "Done" >> /tmp/opengrok.log

