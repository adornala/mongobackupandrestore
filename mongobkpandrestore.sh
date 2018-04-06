#!/bin/sh
# Mongo Backup and restore Script
##################################
while true; do
    read -p " Do you wish to do a Mongo Promotion? Yes or No  -> " yn
    case $yn in
        [Yesyes]* ) 
		echo "========= FROM DATABASE ======"
		read -p " From Database: (example : localhost:27017 ): " F_MONGO_HOSTNAME
		while true; do
		    read -p " Credentials for $F_MONGO_HOSTNAME ? -> " yn
		    case $yn in
		        [Yesyes]* ) 
				read -p " Username? " F_MONGO_USERNAME
				read -s " Password for $F_MONGO_USERNAME? " F_MONGO_PASSWORD
				break;;
		        [Nono]* ) " No probs..."; break;;
		        * ) echo " Please enter something :(";;
		    esac
		done
		echo "=============================="
		echo " Setting up Directory Structure..."
		
		BACKUPS_DIR=$HOME/mongobackups
		
		if ! mkdir -p $BACKUPS_DIR; then
		   echo "Can't create backup directory in $BACKUPS_DIR. Go and fix it!" 1>&2
		   exit 1;
		fi;
		
		echo " Just a Second let me backup our Jewelery so we can transport it"
		
		cd $BACKUPS_DIR
		
		mongodump -d $F_MONGO_DATABASE  if [ "$F_DBUSERNAME" != "" ] then "--username $F_DBUSERNAME --password $F_DBPASSWORD" fi
		
		if [ $? -eq 0 ]; then
			echo " Back up was sucessful. Let's ship it now.."
			echo "======== TO DATABASE ========="
			read -p " Database Host (example: localhost:27017 ) -> " T_MONGO_HOSTNAME
			while true; do
			    read -p " Credentials for $T_MONGO_HOSTNAME ? -> " yn
			    case $yn in
			        [Yesyes]* ) 
					read -p " Hmm.. What's the username? " T_MONGO_USERNAME
					read -s " Password for $F_MONGO_USERNAME? " T_MONGO_PASSWORD
					break;;
			        [Nono]* ) " No probs..."; break;;
			        * ) echo " Please enter something :(";;
			    esac
			done
			echo "=============================="

			if [ $? -ne 0 ]; then
				echo " Something went wrong. Backup folder not found. Exiting..."
			else
				echo " Starting restore process.."
				mongorestore --drop -d $T_MONGO_DATABASE  if [ "$T_DBUSERNAME" != "" ] then "--username $T_DBUSERNAME --password $T_DBPASSWORD" fi
			fi
			if [ $? -eq 0 ]; then
				echo " Restore was sucessful. Packages delivered.."
				BACKUP_NAME=dump-$( date +%T )
				mv -rf dump $BACKUP_NAME
				tar -zcvf ~/mongobackups/$BACKUP_NAME.tgz $BACKUP_NAME
				rm -rf $BACKUP_NAME
				## Running a REST call to Update URL's as part of promotion
				while true; do
				    echo " This part helps in updating URL's are part of this promotion "
					read -p " Enter the KYC QuestionBank URL you will be using for updating URLS : " url
				    case $url in
				        [*]* ) 
						read -p " Username : " S_USERNAME
						read -s " Password : " S_PASSWORD
						response=$(curl --write-out %{http_code} --silent --user S_USERNAME:S_PASSWORD -H "Content-Type: application/json" -X POST -d '{"username":"xyz","password":"xyz"}' --output /dev/null "$url/api/login")
						if [ "$response" = "200" ];
							then
						  	  echo "Processed request sucessfully"
							else
						  	  echo "Primary Site Down, Secondary Site is Down"
					  	fi
						break;;
				        * ) echo " Please enter something :(";;
				    esac
				done
			else
				echo " Mongo restore failed due to exception"
			fi
		else 
			echo " Please fix above errors and try again!" 
		fi
		exit;;
        [Nono]* ) exit;;
        * ) echo " Please answer yes or no.";;
    esac
done
