#!/bin/bash

serviceIsRunning=false
var1=`/etc/init.d/tomcat status | grep running | grep -v not | wc -l`
        if [ "$var1" == '1' ]
                then
                        serviceIsRunning=true
                        echo "0:200:Running"
        fi
        if [ $serviceIsRunning == false ]
                then
                        echo "2:404:Stop"
        fi

