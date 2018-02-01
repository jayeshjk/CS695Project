docker rm -f prime
docker run --name prime --rm busybox:latest /bin/sh -c ' 
i=3;
flag=0;
tem=2;

while true
do
        temp=`echo $i`;

        while [ $temp -ne $tem ]
        do
                temp=`expr $temp - 1`;
                n=`expr $i % $temp`;

                if [ $n -eq 0 -a $flag -eq 0 ]
                then
                        flag=1;
                fi
        done

        if [ $flag -eq 0 ]
        then
                echo $i;
        else
                flag=0;
        fi
        i=`expr $i + 1`;
        sleep 1;
done'
