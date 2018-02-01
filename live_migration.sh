#!/bin/bash -e
#
function run-vg-cmd() {
    pushd $1
    eval $2
    popd
}

function usage() {
    echo "Usage: $0 container from-vagrant-dir to-vagrant-dir"
}

if [ $# -eq 0 ]
then
    #echo "$0: Migrating a Docker container from one vagrant host to another"
    #echo ""
    usage
    exit 1
fi

workdir="/tmp/live-migration"
container=$1
vagrant_from=$2
vagrant_to=$3

if test "${container}" = ""; then
    #echo 'container is required'
    #echo ""
    usage
    exit 1
fi

if test "${vagrant_from}" = ""; then
    #echo 'vagrant-from-dir is required'
    #echo ""
    usage
    exit 1
fi

if test "${vagrant_to}" = ""; then
    #echo 'vagrant-to-dir is required'
    #echo ""
    usage
    exit 1
fi

#iteration number
iter=0

# Cleanup first
cd $workdir && sudo rm -rf $container*
#echo "cleanup done."

run-vg-cmd $vagrant_from "sudo vagrant ssh -- sudo rm -rf /tmp/$container"
#echo "cleanup done in $vagrant_from."

# Dump ssh config for scp
run-vg-cmd $vagrant_from "sudo vagrant ssh-config > ssh.config"
#echo "Dump ssh config for scp."

duration1=$SECONDS
# Checkpoint a container and leave it running
run-vg-cmd $vagrant_from "sudo vagrant ssh -- docker checkpoint --image-dir=/tmp/$container --leave-running=true $container"
#echo "Checkpoint a container and leave it running."

# Copy container dump from vagrant to source
run-vg-cmd $vagrant_from "sudo scp -F ssh.config -r vagrant@default:/tmp/$container $workdir/$container$iter"
#echo "Copy container dump from vagrant to source"

#remove $workdir/$container folder at destination
########################To check whether directory $container is being removed at remote host.
eval "sshpass -p 'jayant' ssh jayant@10.15.21.112 -- 'rm -rf $workdir/$container; exit;'"

#copy container dump from source to destination
sudo sshpass -p 'jayant' scp -r $workdir/$container$iter jayant@10.15.21.112:$workdir/$container
#echo "copy container dump from source to destination."


for i in 1 2 3
do
	#remove earlier dump files in vagrant_from
	run-vg-cmd $vagrant_from "sudo vagrant ssh -- sudo rm -rf /tmp/$container"
	#echo "Removed earlier dump from vg-1"
	if [ $i -ne 3 ]
	then
		# Checkpoint a container and leave it running
		run-vg-cmd $vagrant_from "sudo vagrant ssh -- docker checkpoint --image-dir=/tmp/$container --leave-running=true $container"
		#echo "Checkpoint a container in iteration $i and leave it running."
	else
		# Checkpoint a container and stop the container
		run-vg-cmd $vagrant_from "sudo vagrant ssh -- docker checkpoint --image-dir=/tmp/$container --leave-running=false $container"
		#echo "Checkpoint a container for last iteration and stop the container."
		start=$SECONDS
	fi
	
	prev=$iter
	iter=$(expr $iter + 1)	
	# Copy container dump from vagrant to source
	run-vg-cmd $vagrant_from "sudo scp -F ssh.config -r vagrant@default:/tmp/$container $workdir/$container$iter"
	#echo "Copy container dump from vagrant to source"
	
	#echo "before"
	#remove files in change and new_files folder before running genChanges.py
	sudo rm -rf changes
	sudo rm -rf new_files
	python genChanges.py $container$prev $container$iter
	#echo "after"
	#remove file in change and new_files folder at destination
	eval "sshpass -p 'jayant' ssh jayant@10.15.21.112 -- 'rm -rf $workdir/changes; rm -rf $workdir/new_files; exit;'"
	#send the changes and new_files created in this iteration to destination
	sudo sshpass -p 'jayant' scp -r $workdir/changes jayant@10.15.21.112:$workdir/changes
	sudo sshpass -p 'jayant' scp -r $workdir/new_files jayant@10.15.21.112:$workdir/new_files
	#echo "copy changes and new_files folder from source to destination."
	
	#ssh to destination and run merge.py
	eval "sshpass -p 'jayant' ssh jayant@10.15.21.112 -- 'cd $workdir; pwd; python merge.py changes $container new_files'"
done 



#Restore the container at destination in vagrant_to
eval "sshpass -p 'jayant' ssh jayant@10.15.21.112 -- 'cd $vagrant_to; vagrant ssh -- rm -rf /home/vagrant/$container; vagrant ssh-config > ssh.config; scp -F ssh.config -r $workdir/$container vagrant@default:/home/vagrant/$container; vagrant ssh -- docker rm -f $container >/dev/null 2>&1; vagrant ssh -- docker create --name=$container busybox; vagrant ssh -- docker restore --force=true --image-dir=/home/vagrant/$container $container';"

#echo "adf"
duration=$((SECONDS-start))
total=$((SECONDS-duration1))
echo $duration
echo $total
