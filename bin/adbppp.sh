#sudo sysctl net.ipv4.ip_forward=1
sudo iptables -t nat -I POSTROUTING -s 192.168.0.2 -o eth0 -j MASQUERADE
#sudo iptables -I FORWARD --in-interface ppp0 -j ACCEPT
#sudo iptables -I INPUT --in-interface ppp0 -j ACCEPT
sudo `which adb` ppp "shell:pppd nodetach noauth noipdefault defaultroute /dev/tty" nodetach noauth noipdefault notty 192.168.0.1:192.168.0.2
adb shell "setprop net.dns1 172.16.168.26"
adb shell "setprop net.dns2 172.16.188.26"

