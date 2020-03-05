wgetsh() {
	# 传入下载的文件位置和下载地址，自动下载到${mbtmp}，若成功则移到下载位置
	[ -z "$1" -o -z "$2" ] && return 1
	[ -x /opt/bin/curl ] && alias curl=/opt/bin/curl
	local wgetfilepath="$1"
	local wgetfilename=$(basename $wgetfilepath)
	local wgetfiledir=$(dirname $wgetfilepath)
	local wgeturl="$2"
	[ ! -d "$wgetfiledir" ] && mkdir -p $wgetfiledir
	[ ! -d ${mbtmp} ] && mkdir -p ${mbtmp}
	rm -rf ${mbtmp}/${wgetfilename}
	if command -v wget-ssl &> /dev/null; then
		wget-ssl -q --no-check-certificate --tries=1 --timeout=10 -O "${mbtmp}/${wgetfilename}" "$wgeturl"
		[ $? -eq 0 ] && result="200"
	else
		result1=$(curl -skL --connect-timeout 10 -m 20 -w %{http_code} -o "${mbtmp}/${wgetfilename}" "$wgeturl")
	fi
	[ -f "${mbtmp}/${wgetfilename}" ] && result2=$(du -sh "${mbtmp}/${wgetfilename}" 2> /dev/null | awk '{print$1}')
	if [ "$result" = "200" ] && [ "$result2" != '0' ]; then
		chmod +x ${mbtmp}/${wgetfilename} > /dev/null 2>&1
		mv -f ${mbtmp}/${wgetfilename} $wgetfilepath > /dev/null 2>&1
		return 0
	else
		rm -rf ${mbtmp}/${wgetfilename}
		return 1
	fi

}

wgetlist() {
	[ -z "$1" ] && echo -n ""
	if command -v wget-ssl &> /dev/null; then
		wget --no-check-certificate -q -O - "$1"
	else
		curl -kfsSl "$1"
	fi
}

base_encode() {
	if [ -z "${1}" ]; then
		echo -n "" 
	else
		if command -v base64-encode &> /dev/null; then
			echo -n "$*" | base64-encode
		else
			echo -n "$*" | baseutil --b64
		fi
	fi
}

base_decode() {
	if [ -z "${1}" ]; then
		echo -n "" 
	else
		if command -v base64-decode &> /dev/null; then
			echo -n "$*" | base64-decode
		else
			echo -n "$*" | baseutil --b64 -d
		fi
	fi
}