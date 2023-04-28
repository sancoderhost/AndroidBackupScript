#!/bin/bash 
mapfile -t packages < <(adb shell pm list packages -3  | cut -d : -f 2 )
pkgcount=${#packages[@]}
count=0
count2=0
count3=0
countreal=0
for pkg in "${packages[@]}";
do
		((countreal++))
		echo -e "\e[31m____________________[acessing ...$pkg] "$countreal/$pkgcount"\e[0m$1______________________"
		apkpath="$(adb shell pm path "$pkg" |cut -d : -f 2  )"
		mkdir -p $pkg 
		echo -e "\e[33m[pulling apk] of "$pkg"\e[0m$1  "
		#echo -e "\e[32m[pulling]\e[0m$1 apk of   "$pkg"..... \e[32m$j\e[0m"
		if adb pull "$apkpath" "$pkg/"
		then
				(( count++ ))
				echo -e "\e[32m[-----apk progress ("$count"/"$pkgcount")-----------]\e[0m$1  "
				 #echo " apk of $pkg pulled ----(""$count""/""$pkgcount"")----"
		fi 
		#mkdir -p "$pkg/data/"
		#adb pull "/data/data/$pkg"  "$pkg/data/"


		((count++))
		mapfile -t datas < <( adb shell find /sdcard/Android/ -name $pkg  )
		for i in "${datas[@]}";
		do 
				#echo "pulling external dir of $pkg"
				echo -e "\e[33m[-----external  pulling  -----------]\e[0m$1  "
				mkdir -p  "$pkg/external/"
				#if adb pull "$i" "$pkg/external/"
				#then
				#		echo "done in ...$i"
				#fi 
				pkgsize=$(adb shell du -sb "$i"| awk '{print $1}')
				if adb shell tar   cf - "$i" |pv -s $pkgsize  > "$pkg/external/$( echo "$i" | awk -F / ' { print $3 }' ).tar"
				then
						echo -e "\e[33m[done  pulling of $i  ]\e[0m$1  "
				#		echo " done pulling external of .... $i"
				fi 
		done 
		mkdir -p "$pkg/private/"
		echo "saving file user info to file "
		if adb shell su -c ls -l "/data/data/$pkg/" |awk '{print $3 , $4 , $NF }' >"$pkg/private/permissions"
		then 
				echo "saved permissions"
		fi 
		echo -e "\e[34m[pulling private dir  ]\e[0m$1  "
		#echo "pulling private dir"
		pkgsize2=$(adb shell su -c du -sb "/data/data/$pkg" |awk '{print $1}')
		if adb shell su -c tar  cf - "/data/data/$pkg" | pv -s $pkgsize2  > "$pkg/private/data.tar" 
		then 
				(( count2++ ))
				echo -e "\e[34m[private dir of $pkg pulled  ]\e[0m$1  "
				echo "private dir of $pkg  pulled "
				echo "----(""$count2""/""$pkgcount"")----"
		fi 
		clear;
done
