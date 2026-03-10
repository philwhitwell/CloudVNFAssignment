#!/bin/bash

#SERVER_IP="10.244.1.66" #This was the server IP for the shared ip between VM and AKS
SERVER_IP="51.13.186.89" #This is the VM internal IP address for sending from Macbook
UE_IP="10.45.0.3"
DURATION=60
WAIT_TIME=30

echo "Starting UPF traffic test"
echo "Server: $SERVER_IP"
echo "UE IP: $UE_IP"

run_test () {
    RATE=$1
    echo ""
    echo "======================================"
    echo "Running iperf3 test at $RATE"
    echo "======================================"

    iperf3 -c $SERVER_IP -B $UE_IP -u -b $RATE -t $DURATION

    echo ""
    echo "Waiting $WAIT_TIME seconds before next test..."
    sleep $WAIT_TIME
}

echo "Initial idle period for baseline metrics..."
sleep $WAIT_TIME

run_test 10M
run_test 50M
run_test 100M
run_test 200M

echo ""
echo "Traffic tests complete"
echo "Allowing final cooldown period..."

sleep $WAIT_TIME
echo "Done."