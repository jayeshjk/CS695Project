docker rm fibo
docker run --name fibo --rm busybox:latest /bin/sh -c 'x=0;
  y=1;
  i=2;
  echo "Fibonacci Series up to $n terms :"
  echo "$x"
  echo "$y"
  while true
  do
      i=`expr $i + 1 `;
      z=`expr $x + $y `;
      echo "$z";
      x=$y;
      y=$z;
      sleep 1;
  done' 
