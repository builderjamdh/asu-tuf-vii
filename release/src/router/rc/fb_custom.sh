#!/bin/sh
# 魔改固件: 防火墙自定义规则 (M35)
# 从 NVRAM 读取自定义 IPv4/IPv6 规则并应用
. /usr/sbin/helper.sh

IPC_FILE="/tmp/fb_custom_ipv4.filter"
IPC6_FILE="/tmp/fb_custom_ipv6.filter"

start_fb_custom() {
	if [ "$(nvram get fb_custom_enable)" != "1" ]; then
		rm -f "$IPC_FILE" "$IPC6_FILE"
		return 0
	fi

	# IPv4 rules
	rm -f "$IPC_FILE"
	if [ -n "$(nvram get fb_ipv4_rules)" ]; then
		nvram get fb_ipv4_rules > "$IPC_FILE"
	fi

	# IPv6 rules
	rm -f "$IPC6_FILE"
	if [ -n "$(nvram get fb_ipv6_rules)" ]; then
		nvram get fb_ipv6_rules > "$IPC6_FILE"
	fi

	# Apply IPv4
	if [ -f "$IPC_FILE" ] && [ -s "$IPC_FILE" ]; then
		iptables -N FB_CUSTOM 2>/dev/null
		iptables -F FB_CUSTOM
		while IFS= read -r line; do
			[ -z "$line" ] && continue
			echo "$line" | grep -q "^#" && continue
			eval "$line"
		done < "$IPC_FILE"
		iptables -t filter -I FORWARD -j FB_CUSTOM
		iptables -t filter -I INPUT -j FB_CUSTOM
	fi

	# Apply IPv6
	if [ -f "$IPC6_FILE" ] && [ -s "$IPC6_FILE" ]; then
		ip6tables -N FB_CUSTOM6 2>/dev/null
		ip6tables -F FB_CUSTOM6
		while IFS= read -r line; do
			[ -z "$line" ] && continue
			echo "$line" | grep -q "^#" && continue
			eval "$line"
		done < "$IPC6_FILE"
		ip6tables -t filter -I FORWARD -j FB_CUSTOM6
		ip6tables -t filter -I INPUT -j FB_CUSTOM6
	fi

	logger "fb_custom: IPv4 $(wc -l < "$IPC_FILE" 2>/dev/null || echo 0) rules"
	logger "fb_custom: IPv6 $(wc -l < "$IPC6_FILE" 2>/dev/null || echo 0) rules"
}

stop_fb_custom() {
	iptables -t filter -D FORWARD -j FB_CUSTOM 2>/dev/null
	iptables -t filter -D INPUT -j FB_CUSTOM 2>/dev/null
	iptables -F FB_CUSTOM 2>/dev/null
	iptables -X FB_CUSTOM 2>/dev/null
	ip6tables -t filter -D FORWARD -j FB_CUSTOM6 2>/dev/null
	ip6tables -t filter -D INPUT -j FB_CUSTOM6 2>/dev/null
	ip6tables -F FB_CUSTOM6 2>/dev/null
	ip6tables -X FB_CUSTOM6 2>/dev/null
	rm -f "$IPC_FILE" "$IPC6_FILE"
}

case "$1" in
start|restart)
	stop_fb_custom
	start_fb_custom
	;;
stop)
	stop_fb_custom
	;;
*)
	echo "usage: $0 {start|stop|restart}" >&2
	exit 1
	;;
esac
