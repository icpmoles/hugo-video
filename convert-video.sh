#! /bin/bash

target_dir="../../content/post"

# You can set: global_var will be passed to all ffmpeg commands; ffbin is the ffmpeg command or directory
global_var=" -hide_banner"
ffbin="ffmpeg.exe"

stats=$"Size comparison: \n"
t_stats=""
convertion=0

cd $target_dir
post=$(pwd)
echo "Found working directory: $post" 
shopt -s nullglob
for d in */ ; do
    echo "Searching for video files in $d"
    cd $d
    
    for v in *.source.*
    do
        convertion=0
        t_stats=""
        h=$(ffprobe -v error -select_streams v -show_entries stream=height -of csv=p=0:s=x $v)
        br=$(ffprobe -v error -select_streams v -show_entries format=bit_rate -of csv=p=0:s=x $v)
            echo -n "✅ Found source file $v, height: $h, "
            t_stats+=$"Input File: $d$v Bitrate: $br kb \n"
            # Populate the FFMPEG parameters depending on the resolution and the destination format
            # Target bitrate from:
            # H264: https://www.lighterra.com/papers/videoencodingh264/
            # VP9: https://developers.google.com/media/vp9/settings/vod
            # AV1: VP9 target bitrate * 80%
            # HEVC: VP9 target bitrate * 80%
            if (($h<=300))
            then
                echo "using 240p settings"
                mp4_sett="-c:v libx264 -b:v 250k -c:a libfdk_aac  -b:a 64k"
                webm_sett="-b:v 150k -minrate 75k -maxrate 218k -tile-columns 0 -g 240 -threads 2 -quality best -crf 37 -c:v libvpx-vp9 -c:a libopus  -b:a 64k -speed 1"
                av1_sett="-c:v libsvtav1  -b:v 120k -c:a libopus  -b:a 64k"
                hevc_sett="-c:v libx265 -b:v 120k -c:a libfdk_aac  -b:a 64k -x265-params"
            elif ((301<=$h && $h<=420))
            then
                echo "using 360p settings"
                mp4_sett="-c:v libx264 -b:v 350k -c:a libfdk_aac  -b:a 64k"
                webm_sett="-b:v 276k -minrate 138k -maxrate 400k -tile-columns 1 -g 240 -threads 4 -quality best -crf 36 -c:v libvpx-vp9 -c:a libopus -b:a 64k -speed 1"
                av1_sett="-c:v libsvtav1  -b:v 220k -c:a libopus  -b:a 64k"
                hevc_sett="-c:v libx265 -b:v 220k -c:a libfdk_aac  -b:a 64k -x265-params"               
            elif ((421<=$h && $h<=600))
            then
                echo "using 480p settings"
                mp4_sett="-c:v libx264 -b:v 1000k -c:a libfdk_aac  -b:a 64k"
                webm_sett="-b:v 750k -minrate 375k -maxrate 1088k -tile-columns 1 -g 240 -threads 4 -quality good -crf 33 -c:v libvpx-vp9 -c:a libopus -b:a 64k  -speed 1"
                av1_sett="-c:v libsvtav1  -b:v 600k -c:a libopus  -b:a 64k"
                hevc_sett="-c:v libx265 -b:v 600k -c:a libfdk_aac  -b:a 64k -x265-params"
            elif ((601<=$h && $h<=900))
            then
                echo "using 720p settings"
                mp4_sett="-c:v libx264 -b:v 1500k -c:a libfdk_aac  -b:a 64k"
                webm_sett="-b:v 1024k  -minrate 512k -maxrate 1485k -tile-columns 2 -g 240 -threads 8 -quality good -crf 32 -c:v libvpx-vp9 -c:a libopus -b:a 128k -speed 4 "
                av1_sett="-c:v libsvtav1  -b:v 820k -c:a libopus  -b:a 64k"
                hevc_sett="-c:v libx265 -b:v 820k -c:a libfdk_aac  -b:a 128k -x265-params"
            elif ((901<=$h && $h<=1260))
            then
                echo "using 1080p settings"
                mp4_sett="-c:v libx264 -b:v 2500k -c:a libfdk_aac  -b:a 128k"
                webm_sett="-b:v 1800k -minrate 900k -maxrate 2610k -tile-columns 2 -g 240 -threads 8  -quality good -crf 31 -c:v libvpx-vp9 -c:a libopus  -b:a 128k -speed 4"
                av1_sett="-c:v libsvtav1  -b:v 1440k -c:a libopus  -b:a 64k"
                hevc_sett="-c:v libx265 -b:v 1440k -c:a libfdk_aac  -b:a 128k -x265-params"
            elif ((1261<=$h && $h<=1800))
            then
                echo "using 1440p settings"
                mp4_sett="-c:v libx264 -b:v 9000k -c:a libfdk_aac  -b:a 384k"
                webm_sett="-b:v 6000k -minrate 3000k -maxrate 8700k -tile-columns 3 -g 240 -threads 16 -quality good -crf 24 -c:v libvpx-vp9 -c:a libopus  -b:a 128k  -speed 4"
                av1_sett="-c:v libsvtav1  -b:v 4800k -c:a libopus  -b:a 64k"
                hevc_sett="-c:v libx265 -b:v 4800k -c:a libfdk_aac  -b:a 384k -x265-params"
            elif ((1801<=$h ))
            then
                echo "using 2160p settings"
                mp4_sett="-c:v libx264 -b:v 15000k -c:a libfdk_aac  -b:a 384k"
                webm_sett="-b:v 12000k -minrate 6000k -maxrate 17400k -tile-columns 3 -g 240 -threads 24 -quality good -crf 15 -c:v libvpx-vp9 -c:a libopus    -b:a 128k -speed 4"
                av1_sett="-c:v libsvtav1  -b:v 9600k -c:a libopus  -b:a 64k"
                hevc_sett="-c:v libx265 -b:v 9600k -c:a libfdk_aac  -b:a 384k -x265-params"
            fi 
            
            # Checks if the destination files already exist 


            # H264 convertion
            if [[ -f "${v%.source.*}.mp4" ]]
            then
                echo "🆗 ${v%.source.*}.mp4 already exists."
            else 
                echo "⏭ ${v%.source.*}.mp4 does not exist."
                convertion=1
                $ffbin -i $v $global_var $mp4_sett -pass 1 -an -f null /dev/null 
                $ffbin -i $v $global_var $mp4_sett -movflags +faststart -pass 2 ${v%.source.*}.mp4
                o_br=$(ffprobe -v error -select_streams v -show_entries format=bit_rate -of csv=p=0:s=x ${v%.source.*}.mp4)
                t_stats+=$" Output File: $d${v%.source.*}.mp4 Bitrate: $o_br kb Final Size: $(echo "scale = 4; 100 * ( $o_br / $br) " | bc)% \n"
            fi

            # VP9 convertion
            if [[ -f "${v%.source.*}.webm" ]]
            then
                echo "🆗 ${v%.source.*}.webm already exists."
            else 
                echo "⏭ ${v%.source.*}.webm does not exist."
                convertion=1
                $ffbin -i $v $global_var $webm_sett -pass 1 -an -f null /dev/null 
                $ffbin -i $v $global_var $webm_sett -pass 2 ${v%.source.*}.webm
                o_br=$(ffprobe -v error -select_streams v -show_entries format=bit_rate -of csv=p=0:s=x ${v%.source.*}.webm)
                echo $o_br
                t_stats+=$" Output File: $d${v%.source.*}.webm Bitrate: $o_br kb Final Size: $(echo "scale = 4; 100 * ( $o_br / $br) " | bc)% \n"
            fi

            # AV1 convertion
            if [[ -f "${v%.source.*}.av1.webm" ]]
            then
                echo "🆗 ${v%.source.*}.av1.webm already exists."
            else 
                echo "⏭ ${v%.source.*}.av1.webm does not exist."
                convertion=1
                $ffbin -i $v $global_var $av1_sett -pass 1 -an -f null /dev/null 
                $ffbin -i $v $global_var $av1_sett -pass 2 ${v%.source.*}.av1.webm
                o_br=$(ffprobe -v error -select_streams v -show_entries format=bit_rate -of csv=p=0:s=x ${v%.source.*}.av1.webm)
                t_stats+=$" Output File: $d${v%.source.*}.av1.webm Bitrate: $o_br kb Final Size: $(echo "scale = 4; 100 * ( $o_br / $br) " | bc)% \n"
            fi

            # HEVC convertion
            if [[ -f "${v%.source.*}.hevc.mp4" ]]
            then
                echo "🆗 ${v%.source.*}.hevc.mp4 already exists."
            else 
                echo "⏭ ${v%.source.*}.hevc.mp4 does not exist."
                convertion=1
                $ffbin -i $v $global_var $hevc_sett pass=1 -an -f null /dev/null 
                $ffbin -i $v $global_var $hevc_sett  pass=2  ${v%.source.*}.hevc.mp4
                o_br=$(ffprobe -v error -select_streams v -show_entries format=bit_rate -of csv=p=0:s=x ${v%.source.*}.hevc.mp4)
                t_stats+=$" Output File: $d${v%.source.*}.hevc.mp4 Bitrate: $o_br kb Final Size: $(echo "scale = 4; 100 * ( $o_br / $br) " | bc)% \n"
            fi

            if [ $convertion -eq 1 ]
            then
                stats+=$t_stats
            fi
            
    done
    # cd $post
done

echo -e "$stats"