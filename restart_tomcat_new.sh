#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
logPath="$Dir/log_tomcat"

log_message() {
        echo -e $1 >> $logPath
}

backup_log_catalina() {

	year=$(date +"%Y")
	month=$(date +"%m")
	day=$(date +"%d")

	hour=$(date +"%H")
	munites=$(date +"%M")
	second=$(date +"%S")

	hms=$hour$munites$second
	ymd=$year$month$day
	
	DIRECTORY="$CURRENT_DIR"/log_catalina_backup/"$ymd"

        if [ -d "$DIRECTORY" ];
                then
                        echo "Folder $DIRECTORY exists"
				cd /var/log/tomcat
			        tar -czvf "$CURRENT_DIR"/log_catalina_backup/"$ymd"/catanina_"$ymd"_"$hms".tar.gz catalina.*
			echo "Backup Catalina.out Done !!!"

        elif [ ! -d "$DIRECTORY" ];
                then
                        echo "Folder $DIRECTORY doesnt exists"
  	                      mkdir -p "$CURRENT_DIR"/log_catalina_backup/"$ymd"
			echo "Creating Foleder $DIRECTORY Done !!!"
				cd /var/log/tomcat
                                tar -czvf "$CURRENT_DIR"/log_catalina_backup/"$ymd"/catanina_"$ymd"_"$hms".tar.gz catalina.*
			echo "Backup Catalina.out Done !!!"
        fi	
}

remove_log_catalina() {

        for i in `seq 30 40`; do
                year=$(date -d "$i days ago" +"%Y")
                month=$(date -d "$i days ago" +"%m")
                day=$(date -d "$i days ago" +"%d")
                log_message "remove folder log old $CURRENT_DIR/$ymd"
                ymd=$year$month$day
                rm -rf "$CURRENT_DIR"/log_catalina_backup/"$ymd"
        done
}


restart_tomcat() {

	status_tomcat=$(/etc/init.d/tomcat status | grep running | grep -v not | wc -l)
	echo "--- PID = $status_tomcat-------- Pid Tomcat > 0 Kill And Start Or Status Tomcat = 0 Start"
	if [ "$status_tomcat" -ne 1 ]
		then
			echo "------------------- Backup Log Catalina Out !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
				backup_log_catalina
			echo "------------------- Begin Clear Cache Tomcat!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                                rm -rf /var/log/tomcat/*
			echo "-----`date`------- Status Return Tomcat Is $status_tomcat !!!!!!!!!!!!!!!!!!!!!!!!!!!"
			echo ".........Tomcat Is Not Start And Waiting Start Service Tomcat..................."
				/etc/init.d/tomcat start
			echo "------------ Start Service Tomcat Complete !!!!!!! ------------"
	else
		echo "--------`date`----------- Status Return Tomcat Is $status_tomcat ---------------------------"
		echo "------------  Tomcat Is Down And Waiting Restart Service Tomcat !!!!!!!.........."
				PID_tomcat=$(ps -ef | grep tomcat | grep java | awk '{print $2}')
				kill -9 $PID_tomcat
		echo "------------------- Backup Log Catalina Out !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
                                backup_log_catalina
		echo "------------------- Begin Clear Cache Tomcat!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
			        rm -rf /var/log/tomcat/*
				sleep 2
				/etc/init.d/tomcat start
		echo "------------ Start Service Tomcat Complete !!!!!!! ------------"
	fi
}

check_login_nologin(){

        restart_tomcat
        while true
        do
                get_value_login_false=`sed -n '/postUrl:/p' /var/log/tomcat/catalina.out | grep -v "/j_spring_security_check" | wc -l`
                get_value_login_true=`sed -n '/postUrl: \/\j_spring_security_check/p' /var/log/tomcat/catalina.out | wc -l`

                echo "User login false $login_false"
                echo "User login true $login_true"

                value_default_login_true=1
                value_default_login_true=0

                if [ $get_value_login_true -ge 2 ] && [ $get_value_login_false -le 0 ];
                        then
                                break
                elif [ $get_value_login_true -le 0 ] && [ $get_value_login_false -ge 2 ];
                        then
                        restart_tomcat
                fi
                sleep 5

        done
}




log_message "\n\n\n\n\n----------- Checking System Info -----------"
log_message "Checking Time:  $(date)"
check_login_nologin
