docker rm -f mem
docker run --name mem --rm busybox:latest /bin/sh -c '
array0=0;
max_delay=1000;
size=1000
for index in $(seq $size); do
    eval array$index=0;
done
while true;
do
	times=`expr $RANDOM % 5 `;
	echo $times;
	for index in echo `seq $times `; do
		position=`expr $RANDOM % $size `;
		eval array$position=100;
		#eval echo \$array$position;
	done
	delay=`expr $RANDOM % $max_delay `
	delay=`expr $delay / 2000 `
	echo $delay
	sleep $delay;
done
'

