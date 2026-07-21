#!bin/bash

set -x

# echo "sudo ip route add 139.9.131.65 via 100.69.96.1 dev wlp0s20f3 table main"

ssh -R 8080:localhost:8080 -R 8081:localhost:8081 -p 41422 -i ~/.ssh/id_ed25519 huawei@139.9.131.65
