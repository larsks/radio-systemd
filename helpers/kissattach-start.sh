#!/bin/bash
#
# Originally from https://github.com/la5nta/pat/blob/master/share/bin/axup

set -eu

wait_for_tty=0

while getopts w ch; do
	case $ch in
	w)
		wait_for_tty=1
		;;
	*)
		exit 2
		;;
	esac
done
shift $((OPTIND - 1))

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Usage: $0 [axport] [tty]" >&2
	exit 1
fi

ax25_port=$1
ax25_tty=$2

ax25_speed=$(awk -v port="${ax25_port}" '$1 == port {print $3}' /etc/ax25/axports)

declare -A params

if [ "${ax25_speed}" = "9600" ]; then
	params=(
		[paclen]=256 [txdelay]=100 [txtail]=100 [slottime]=100 [persist]=80
		[window]=4 [t1]=3100 [t2]=800 [t3]=300000 [idle]=100000 [retry]=5 [connect_mode]=2
	)
elif [ "${ax25_speed}" = "1200" ]; then
	params=(
		[paclen]=128 [txdelay]=300 [txtail]=100 [slottime]=100 [persist]=80
		[window]=4 [t1]=2000 [t2]=1000 [t3]=300000 [idle]=100000 [retry]=5 [connect_mode]=2
	)
else
	echo "Invalid speed $ax25_speed" >&2
	exit 1
fi

if ((wait_for_tty)); then
	while :; do
		[ -c "${ax25_tty}" ] && break
		echo "waiting for $ax25_tty"
		sleep 1
	done
fi

/usr/sbin/kissattach -l "${ax25_tty}" "${ax25_port}" -m "${params[paclen]}"

/usr/sbin/kissparms -p "${ax25_port}" -c 1 -f n \
	-t "${params[txdelay]}" \
	-l "${params[txtail]}" \
	-s "${params[slottime]}" \
	-r "${params[persist]}"

echo "${params[window]}" >/proc/sys/net/ax25/ax0/standard_window_size  # 2-7 (max frames)
echo "${params[paclen]}" >/proc/sys/net/ax25/ax0/maximum_packet_length # 1-512 (paclen)
echo "${params[t1]}" >/proc/sys/net/ax25/ax0/t1_timeout                # (Frack /1000 = seconds)
echo "${params[t2]}" >/proc/sys/net/ax25/ax0/t2_timeout                # (RESPtime /1000 = seconds)
echo "${params[t3]}" >/proc/sys/net/ax25/ax0/t3_timeout                # (Check /1000 = seconds)
echo "${params[idle]}" >/proc/sys/net/ax25/ax0/idle_timeout            # (/10000(?) = seconds)
echo "${params[retry]}" >/proc/sys/net/ax25/ax0/maximum_retry_count    # n
echo "${params[connect_mode]}" >/proc/sys/net/ax25/ax0/connect_mode    # 0 = None, 1 = Network, 2 = All
