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
    ./apps/APM1 $address & 
    ./apps/APM2 $address &
    ./apps/APM3 $address &
    ./apps/APM4 $address &
    ./apps/APM5 $address &
    ./apps/APM6 $address &
    #wait
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

# Get ip
result=$(getAddress)

# Call 
call $result


# Cleanup existing APM*.txt files so we start fresh
if [ -f APM1_metrics.csv ]
then
    rm APM*.csv
fi

# Get metrics
seconds=0
while true 
do
    sleep 5
    seconds=$(( $seconds + 5 ))
    psmetrics $seconds 
done
