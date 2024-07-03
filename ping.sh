#!/bin/bash

CURRENT_PUBLIC_IP=$1
CURRENT_PRIVATE_IP=$2
NEXT_PRIVATE_IP=$3

ssh -o StrictHostKeyChecking=no -i assessment-tf.pem ubuntu@${CURRENT_PUBLIC_IP} /bin/bash <<EOF
if ping -c 1 ${NEXT_PRIVATE_IP} &> /dev/null; then
    echo "ping from ${CURRENT_PRIVATE_IP} to ${NEXT_PRIVATE_IP} is successfull" 
else 
    echo "ping from ${CURRENT_PRIVATE_IP} to ${NEXT_PRIVATE_IP} failed" 
fi
EOF
