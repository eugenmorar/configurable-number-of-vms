#!/bin/bash

CURRENT_INDEX=$1
NEXT_INDEX=$2
CURRENT_PUBLIC_IP=$3
CURRENT_PRIVATE_IP=$4
NEXT_PRIVATE_IP=$5

ssh -o StrictHostKeyChecking=no -i assessment-tf.pem ubuntu@${CURRENT_PUBLIC_IP} /bin/bash <<EOF
if ping -c 1 ${NEXT_PRIVATE_IP} &> /dev/null; then
    echo "ping from VM[${CURRENT_INDEX}]-${CURRENT_PRIVATE_IP} -> VM[${NEXT_INDEX}]-${NEXT_PRIVATE_IP} is successfull" 
else 
    echo "ping from VM[${CURRENT_INDEX}]-${CURRENT_PRIVATE_IP} -> VM[${NEXT_INDEX}]-${NEXT_PRIVATE_IP} failed" 
fi
EOF
