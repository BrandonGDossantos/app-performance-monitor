#/bin/bash

# Kills all application processes using pkill and string
cleanup() {
    echo  -e "\nThis script was in an infinite while loop for $SECONDS seconds"
    pkill -f "APM1"
    pkill -f "APM2"
    pkill -f "APM3"
    pkill -f "APM4"
    pkill -f "APM5"
    pkill -f "APM6"
    pkill -f "ifstat -d 1"
}
trap cleanup EXIT

# Get NIC ip
getAddress() {
    ip=$(hostname -I)
    echo $ip
}


# Call processes with address and background
call() {
    address=$1
    ifstat -d 1
    ./apps/APM1 $address & 
    ./apps/APM2 $address &
    ./apps/APM3 $address &
    ./apps/APM4 $address &
    ./apps/APM5 $address &
    ./apps/APM6 $address &
}

# Get Process Metrics
psmetrics() {
    i=1
    while [ $i -lt 7 ]
    do
        data=$(ps aux | grep "APM$i" | grep -v "grep" | awk -F \  '{OFS=","; print $3,$4}')
        echo "$1,$data" >> APM$i\_metrics.csv
        (( i++ ))
    done
}

sysmetrics() {
    disk_writes=$(iostat | grep sda | awk -F \  '{print $4}')
    disk_space_kb=$(df | grep "centos-root" | awk -F \  '{print $4}')
    available_disk_space=$(( $disk_space_kb / 1024 ))
    # will need to tx/rx data rate of "ens33" for final submission
    ifout=$(ifstat en* | grep en | awk -F \  '{print $7,$9}')
    rx=$(echo $ifout | awk -F \  '{print $1}') 
    tx=$(echo $ifout | awk -F \  '{print $2}') 
    rx=${rx//K}
    tx=${tx//K}
    echo "$1,$rx,$tx,$disk_writes,$available_disk_space" >> system_metrics.csv 

}

# Get ip
result=$(getAddress)

# Call 
call $result


# Cleanup existing APM*.txt files so we start fresh
if [ -f system_metrics.csv ]
then
    rm APM*.csv
    rm system_metrics.csv
fi

# Get metrics
SECONDS=0
while true 
do
    sleep 5
    psmetrics $SECONDS
    sysmetrics $SECONDS
done
