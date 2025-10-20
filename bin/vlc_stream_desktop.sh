cvlc screen:// :screen-fps=12.0 :live-caching=300 --sout '#transcode{vcodec=h264,vb=800,scale=Auto,width=1280,height=720,acodec=none,scodec=none}:rtp{sdp=rtsp://:8554/live}'
#vlc rtsp://192.168.1.12:8554/live
