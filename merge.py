#How to run
#python merge.py path_to_changes_folder path_to_old_files_folder path_to_receive_new_filesd_folder

import sys
import os
import shutil

path_to_changes=sys.argv[1]
path_to_old=sys.argv[2]
path_to_receive_new_files = sys.argv[3]

#copy all files from files_to_send folder to old_folder
receive_files=os.listdir(path_to_receive_new_files);
total_file_receive = len(receive_files)
print total_file_receive;
for i in range(total_file_receive):
	try:
		shutil.copy(path_to_receive_new_files+"/"+receive_files[i], path_to_old+"/"+receive_files[i]);
	except IOError, e:
		print "Unable to copy file. %s" % e	

changes_files=os.listdir(path_to_changes);
old_files=os.listdir(path_to_old);

total_files=len(changes_files)

for i in range(total_files):
	fd_changes = open(path_to_changes+"/"+changes_files[i], "r")
	if changes_files[i] in old_files:
		old_file_index=old_files.index(changes_files[i]);
		#print changes_files[i], old_file_index, old_files
		fd_file_to_change = open(path_to_old+"/"+old_files[old_file_index], "r+b")
		#first for replace
		line = fd_changes.readline()
		list1 = line.split()
		line = fd_changes.readline()
		list1 = line.split()
		#print list1[0]
		while len(list1) != 0 and list1[0] != "truncate" and list1[0] != "append":
			fd_file_to_change.seek(int(list1[0]) - 1)
			arr = bytearray([int(list1[1])])
			fd_file_to_change.write(arr)
			line = fd_changes.readline()
			list1 = line.split()
		
		if len(list1) != 0 and list1[0] == "truncate":
			#print "inside truncate"
			line = fd_changes.readline()
			list1 = line.split()
			fd_file_to_change.seek(int(list1[0]) - 1)
			fd_file_to_change.truncate()
		
		elif len(list1) != 0 and list1[0] == "append":
			#print "inside append"
			fd_file_to_change.close()
			fd_file_to_change = open(path_to_old+"/"+old_files[old_file_index], "a+b")
			for line in fd_changes:
				list1 = line.split()
				arr = bytearray([int(list1[0])])
				fd_file_to_change.write(arr)
		
		fd_file_to_change.close()
		fd_changes.close()
		#os.rename(path_to_old+"/"+old_files[i],path_to_old+"/"+changes_files[i])
