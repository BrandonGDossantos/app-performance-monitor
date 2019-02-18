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
    wait
}

# Get ip
result=$(getAddress)

# Call 
call $result
