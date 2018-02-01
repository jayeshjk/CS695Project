import os
import shutil
import sys

#put path to old and new directories here.
#no trailing '/' here
path_to_old=sys.argv[1]
path_to_new=sys.argv[2]
path_to_changedir='changes' # one for now, we will keep it as command line argument
if not os.path.exists(path_to_changedir):
	os.makedirs(path_to_changedir);

old_files=os.listdir(path_to_old);
new_files=os.listdir(path_to_new);

total_files=len(new_files) 
for i in range(total_files):
	 new_file=open(path_to_new+"/"+new_files[i],'rb');
	 #print path_to_new+"/"+new_files[i]
	 if new_files[i] in old_files:
		 old_file_index=old_files.index(new_files[i]);
		 old_file=open(path_to_old+"/"+old_files[old_file_index],'rb');
		 change_file=open(path_to_changedir+"/"+new_files[i],'w+');
		 change_file.write("replace\n");
	 
		 truncateFlag=False
		 appendFlag=False
		 counter=0
		 while 1:
			 new_byte=new_file.read(1);
			 old_byte=old_file.read(1);
			 
			 counter=counter+1
			 
			 if not new_byte and not old_byte:
				 break;
				 
			 if not new_byte:
				 truncateFlag=True
				 break;
				 
			 if not old_byte:
				 appendFlag=True
				 break
				
			 #print ord(new_byte);#type(old_byte)
			 if new_byte != old_byte:
				 change_file.write(str(counter)+" "+str(ord(new_byte))+"\n");
				 
		 if truncateFlag==True:
			change_file.write("truncate\n");
			change_file.write(str(counter)+"\n");
			
		 elif appendFlag==True:
			change_file.write("append\n");
			while 1:
				change_file.write(str(ord(new_byte))+"\n");
				new_byte=new_file.read(1);
				if not new_byte:
					break
	 else:
		 if not os.path.exists("new_files"):
			 os.makedirs("new_files");

		 shutil.copy(path_to_new+"/"+new_files[i],"new_files/"+new_files[i]);
