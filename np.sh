docker rm -f np
docker run --name np --rm busybox:latest /bin/sh -c 'i=0; while true; do echo $i; i=$(expr $i + 1); sleep 1;done' 
