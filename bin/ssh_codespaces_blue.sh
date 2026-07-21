#!/bin/bash

set -x

# WiFi
# echo "sudo ip route add 139.9.131.65 via 100.69.96.1 dev wlp0s20f3 table main"
# echo "sudo ip route add 139.9.131.65 via 100.69.38.1 dev wlp0s20f3 table main"

# USB Ethernet
# echo "sudo ip route add 139.9.131.65 via 192.168.22.1 dev enx94bdbe11210e table main"

ssh -R 8080:localhost:8080 -R 8081:localhost:8081 -p 41422 -i ~/.ssh/id_ed25519 huawei@139.9.131.65
