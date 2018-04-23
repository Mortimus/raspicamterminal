#!/bin/bash
# view up to 4 camera's on the ras pi using omxplayer
# viewcam.sh CAMERA_TO_VIEW WIDTH HEIGHT
# ex: viewcam.sh 1 to view camera 1 with auto detecting width and height
# ex: viewcam.sh 0 1920 1080 to view all 4 cameras with width of 1920 and height of 1080
# please configure cam1,cam2,cam3,cam4 accordingly
# if issues please change /boot/config.txt's gpu_mem variable (256 worked for me)

numCam=$1
cam1="rtsp://user:pass@ip:port"
cam2="rtsp://user:pass@ip:port"
cam3="rtsp://user:pass@ip:port"
cam4="rtsp://user:pass@ip:port"
xRes="$(fbset -s | grep -m 1 mode | cut -d \" -f2 | cut -d 'x' -f1)"
yRes="$(fbset -s | grep -m 1 mode | cut -d \" -f2 | cut -d 'x' -f2)"
gpuMem="$(grep gpu_mem /boot/config.txt | cut -d '=' -f2)"
echo "GPU Memory Set:" $gpuMem
expectedGPUMem="256"
if [ "$gpuMem" -lt "$expectedGPUMem" ]
then
	echo "GPU Memory configured too low, please raise to at least" $expectedGPUMem "for 4 camera view."
fi
echo "Cam1:" $cam1
echo "Cam2:" $cam2
echo "Cam3:" $cam3
echo "Cam4:" $cam4
if [ -z "$2" ]
then
	echo "No width provided, auto detecting"
else
	xRes=$2
fi
if [ -z "$3" ]
then
	echo "No height provided, auto detecting"
else
	yRes=$3
fi
echo "Resolution:" $xRes "x" $yRes
camXRes=$(( ($xRes / 2) - 1 ))
camYRes=$(( ($yRes / 2) - 1 ))
xRes=$(( $xRes-1 ))
yRes=$(( $yRes-1 ))
echo "Assuming 4:3 display"
echo "4 camera view will set each camera to" $camXRes "x" $camYRes
if [ -z "$1" ]
then
	echo "Please supply camera to view or 0 for all, ex: viewcam.sh 0 for all"
	echo "Defaulting to viewing all 4 cameras"
	# this is hacky
	set -- "0"
	# exit 1
fi
case $1 in
	0)
		echo "Viewing all 4 cameras"
		omxplayer --no-keys --layer 100 --win 0,0,$camXRes,$camYRes --avdict rtsp_transport:tcp --live $cam1 &
		omxplayer --no-keys --layer 101 --win $camXRes,0,$xRes,$camYRes --avdict rtsp_transport:tcp --live $cam2 &
		omxplayer --no-keys --layer 102 --win 0,$camYRes,$camXRes,$yRes --avdict rtsp_transport:tcp --live $cam3 &
		omxplayer --no-keys --layer 103 --win $camXRes,$camYRes,$xRes,$yRes --avdict rtsp_transport:tcp --live $cam4
		;;
	1)
		echo "Viewing camera 1"
		omxplayer --avdict rtsp_transport:tcp -r --live $cam1
		;;
	2)
		echo "Viewing camera 2"
		omxplayer --avdict rtsp_transport:tcp -r --live $cam2
		;;
	3)
		echo "Viewing camera 3"
		omxplayer --avdict rtsp_transport:tcp -r --live $cam3
		;;
	4)
		echo "Viewing camera 4"
		omxplayer --avdict rtsp_transport:tcp -r --live $cam4
		;;
	*)
		echo "Error with camera selection"
		exit 1
		;;
esac
