set -x

for i in brk fread fstat input malloc mfile mmap rw vmalloc
do
	cp $OUT/system/bin/${i}* .
done
